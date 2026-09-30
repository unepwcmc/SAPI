require 'spec_helper'

describe MappingMatch do
  let(:cites) { MatchableTaxonomy.create!(code: 'CITES_EU', name: 'CITES / EU') }
  let(:pair) { described_class.import_scope(matchable_taxonomy: cites, foreign_matchable_taxonomy: iucn) }
  let(:iucn) { MatchableTaxonomy.create!(code: 'IUCNRL', name: 'IUCN Red List') }
  let(:kew) { MatchableTaxonomy.create!(code: 'Kew', name: 'Kew / WCSP') }

  def match(statuses:, confidence:, nid: '1', foreign_nid: '9', foreign: nil, name: 'n')
    described_class.create!(
      matchable_taxonomy: cites, taxon_nid: nid,
      foreign_matchable_taxonomy: foreign || iucn, foreign_taxon_nid: foreign_nid,
      matched_name: name, matched_name_status: statuses[0],
      foreign_matched_name: name, foreign_matched_name_status: statuses[1],
      match_confidence: confidence, source_file: 'f.csv'
    )
  end


  describe '#match_type' do
    it 'reads the two name statuses together' do
      expect(match(statuses: 'SA', confidence: 'high').match_type).to eq 'SA'
    end
  end

  describe '.resolve' do
    def taxon(taxonomy, nid, status: 'A', name: "name #{nid}", author: nil)
      MappingTaxon.create!(
        matchable_taxonomy: taxonomy, taxon_nid: nid, accepted_taxon_nid: nid,
        name_status: status, scientific_name: name, author_year: author, source_file: 't.csv'
      )
    end

    def backwards_match(statuses:, near_name: 'near', far_name: 'far')
      # Stored with IUCN as d1, as a file naming the pair the other way round
      # would store it.
      described_class.create!(
        matchable_taxonomy: iucn, taxon_nid: '9',
        foreign_matchable_taxonomy: cites, foreign_taxon_nid: '1',
        matched_name: near_name, matched_name_status: statuses[0],
        foreign_matched_name: far_name, foreign_matched_name_status: statuses[1],
        match_confidence: 'low', source_file: 'f.csv'
      )
    end

    def resolve(**)
      described_class.resolve(matchable_taxonomy: cites, taxon_nid: '1', **)
    end

    before { taxon(iucn, '9', name: 'Teratoscincus rustamowi', author: '(Ščerbak, 1979)') }

    it 'finds a match stored with the queried taxon as the near side' do
      match(statuses: 'AA', confidence: 'high')

      expect(resolve.map(&:foreign_taxon_nid)).to eq [ '9' ]
    end

    it 'finds a match stored the other way round, reported from the queried side' do
      backwards_match(statuses: 'AS')

      expect(resolve.map { |m| [ m.matchable_taxonomy_id, m.taxon_nid, m.foreign_matchable_taxonomy_id, m.foreign_taxon_nid ] })
        .to eq [ [ cites.id, '1', iucn.id, '9' ] ]
    end

    it 'mirrors the match type and matched names of a row read backwards' do
      backwards_match(statuses: 'AS', near_name: 'IUCN name', far_name: 'CITES name')

      resolved = resolve.first

      expect([ resolved.match_type, resolved.matched_name, resolved.foreign_matched_name ])
        .to eq [ 'SA', 'CITES name', 'IUCN name' ]
    end

    it 'carries the far side accepted name, not the name that matched' do
      match(statuses: 'AS', confidence: 'low', name: 'Teratoscincus scincus rustamowi')

      resolved = resolve.first

      expect([ resolved.foreign_scientific_name, resolved.foreign_author_year, resolved.foreign_matched_name ])
        .to eq [ 'Teratoscincus rustamowi', '(Ščerbak, 1979)', 'Teratoscincus scincus rustamowi' ]
    end

    it 'returns every match when one taxon maps to many' do
      taxon(iucn, '10')
      match(statuses: 'AA', confidence: 'high', foreign_nid: '9')
      match(statuses: 'SA', confidence: 'really high', foreign_nid: '10')

      expect(resolve.map(&:foreign_taxon_nid)).to contain_exactly('9', '10')
    end

    it 'omits a match naming a far taxon that is not held' do
      match(statuses: 'AA', confidence: 'high', foreign_nid: '404')

      expect(resolve).to be_empty
    end

    it 'does not resolve the far side through a synonym carrying the same id' do
      taxon(iucn, '77', status: 'S')
      match(statuses: 'AA', confidence: 'high', foreign_nid: '77')

      expect(resolve).to be_empty
    end

    it 'omits excluded matches' do
      match(statuses: 'AA', confidence: 'high').update!(exclude: true)

      expect(resolve).to be_empty
    end

    it 'ignores matches for other taxa' do
      match(statuses: 'AA', confidence: 'high', nid: '2')

      expect(resolve).to be_empty
    end

    it 'narrows to the platforms asked for' do
      taxon(kew, '9')
      match(statuses: 'AA', confidence: 'high')
      match(statuses: 'AA', confidence: 'high', foreign: kew)

      expect(resolve(foreign_matchable_taxonomies: [ kew ]).map(&:foreign_matchable_taxonomy_id))
        .to eq [ kew.id ]
    end

    it 'returns read-only records, since a flipped row is not what is stored' do
      backwards_match(statuses: 'AS')

      expect(resolve.first).to be_readonly
    end
  end

  describe '.summary_by_pair' do
    it 'counts a pair once however the source file ordered its two sides' do
      # Which platform a file calls d1 is arbitrary and can differ between
      # exports, so both orientations have to land on the same entry.
      match(statuses: 'AA', confidence: 'high')
      described_class.create!(
        matchable_taxonomy: iucn, taxon_nid: '9',
        foreign_matchable_taxonomy: cites, foreign_taxon_nid: '1',
        matched_name: 'n', matched_name_status: 'A',
        foreign_matched_name: 'n', foreign_matched_name_status: 'A',
        match_confidence: 'high', source_file: 'f.csv'
      )

      expect(described_class.summary_by_pair.values).to contain_exactly(hash_including(matches: 2))
    end

    it 'keys on the two ids sorted' do
      match(statuses: 'AA', confidence: 'high')

      expect(described_class.summary_by_pair.keys).to eq [ [ cites.id, iucn.id ].sort ]
    end
  end

  describe '.unresolved_by_source' do
    def taxon(taxonomy, nid, status)
      MappingTaxon.create!(
        matchable_taxonomy: taxonomy, taxon_nid: nid, accepted_taxon_nid: nid,
        name_status: status, scientific_name: 'n', source_file: 't.csv'
      )
    end

    it 'counts a match whose own side names a taxon that is not held' do
      match(statuses: 'AA', confidence: 'high')
      taxon(iucn, '9', 'A')

      expect(described_class.unresolved_by_source)
        .to contain_exactly(hash_including(matchable_taxonomy_id: cites.id, unresolved: 1))
    end

    it 'counts the far side too' do
      match(statuses: 'AA', confidence: 'high')
      taxon(cites, '1', 'A')

      expect(described_class.unresolved_by_source)
        .to contain_exactly(hash_including(matchable_taxonomy_id: iucn.id, unresolved: 1))
    end

    it 'says nothing when both sides resolve' do
      match(statuses: 'AA', confidence: 'high')
      taxon(cites, '1', 'A')
      taxon(iucn, '9', 'A')

      expect(described_class.unresolved_by_source).to be_empty
    end

    it 'does not accept a synonym as the taxon a match names' do
      # A match names an accepted concept. A synonym happening to carry that
      # identifier is a different row and does not resolve it.
      match(statuses: 'AA', confidence: 'high')
      taxon(cites, '1', 'S')
      taxon(iucn, '9', 'A')

      expect(described_class.unresolved_by_source)
        .to contain_exactly(hash_including(matchable_taxonomy_id: cites.id, unresolved: 1))
    end

    it 'names the file the unresolved matches came from' do
      match(statuses: 'AA', confidence: 'high')
      taxon(iucn, '9', 'A')

      expect(described_class.unresolved_by_source.first[:source_file]).to eq 'f.csv'
    end
  end

  describe '.collapse!' do
    it 'keeps the direct match over a synonym-bridged one that scores higher' do
      # The AA pass matches on name without author, so it can never score above
      # `high` while its bridged siblings reach `really high`. Ranking on
      # confidence alone would report the bridge for a pair that has a direct
      # match - this is the whole reason match type is ordered first.
      direct = match(statuses: 'AA', confidence: 'high', name: 'Handroanthus serratifolius')
      match(statuses: 'SS', confidence: 'really high', name: 'Tabebuia serratifolia')

      described_class.collapse!(pair)

      expect(described_class.pluck(:id)).to eq [ direct.id ]
    end

    it 'prefers a half-synonym match over a fully bridged one' do
      half = match(statuses: 'SA', confidence: 'low')
      match(statuses: 'SS', confidence: 'really high')

      described_class.collapse!(pair)

      expect(described_class.pluck(:id)).to eq [ half.id ]
    end

    it 'ranks the two mirrored half-synonym pairs equally, breaking the tie on confidence' do
      # Which side demoted the name does not make the match stronger.
      stronger = match(statuses: 'AS', confidence: 'high')
      match(statuses: 'SA', confidence: 'low')

      described_class.collapse!(pair)

      expect(described_class.pluck(:id)).to eq [ stronger.id ]
    end

    it 'leaves distinct concept pairs alone' do
      match(statuses: 'AA', confidence: 'high', nid: '1')
      match(statuses: 'AA', confidence: 'high', nid: '2')

      described_class.collapse!(pair)

      expect(described_class.count).to eq 2
    end

    it 'touches only the pair it was given' do
      match(statuses: 'AA', confidence: 'high')
      match(statuses: 'SS', confidence: 'low')
      other = match(statuses: 'SS', confidence: 'low', foreign: kew)

      described_class.collapse!(pair)

      expect(described_class.pluck(:id)).to include other.id
    end
  end
end
