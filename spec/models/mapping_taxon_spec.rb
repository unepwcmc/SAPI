require 'spec_helper'

describe MappingTaxon do
  let(:cites) { MatchableTaxonomy.create!(code: 'CITES_EU', name: 'CITES / EU') }
  let(:iucn) { MatchableTaxonomy.create!(code: 'IUCNRL', name: 'IUCN Red List') }

  def taxon(taxonomy, status, nid: '1', accepted: '1', file: 'cites.csv')
    described_class.create!(
      matchable_taxonomy: taxonomy, taxon_nid: nid, accepted_taxon_nid: accepted,
      name_status: status, scientific_name: 'Panthera leo', source_file: file
    )
  end

  describe '.summary_by_taxonomy' do
    it 'counts names and accepted names apart' do
      taxon(cites, 'A', nid: '1')
      taxon(cites, 'S', nid: '2')

      expect(described_class.summary_by_taxonomy[cites.id])
        .to include(names: 2, accepted: 1)
    end

    it 'reports the file the rows came from' do
      taxon(cites, 'A', file: 'cites-2026.csv')

      expect(described_class.summary_by_taxonomy[cites.id][:source_file]).to eq 'cites-2026.csv'
    end

    it 'leaves out a platform holding nothing, so the caller can tell it apart from zero' do
      taxon(cites, 'A')

      expect(described_class.summary_by_taxonomy).not_to have_key iucn.id
    end
  end

  describe '.lookup' do
    it 'finds an accepted name' do
      accepted = taxon(cites, 'A', nid: '7')

      expect(described_class.lookup(matchable_taxonomy: cites, taxon_nid: '7')).to eq [ accepted ]
    end

    it 'ignores a synonym carrying the same identifier' do
      # CITES issues its synonyms their own ids, so a bare where on taxon_nid
      # would return the synonym rather than nothing.
      taxon(cites, 'S', nid: '7', accepted: '1')

      expect(described_class.lookup(matchable_taxonomy: cites, taxon_nid: '7')).to be_empty
    end
  end
end
