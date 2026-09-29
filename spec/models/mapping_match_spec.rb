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
