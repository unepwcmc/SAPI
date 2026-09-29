require 'spec_helper'

describe MatchableTaxonomy do
  def platform(code = 'IUCNRL')
    described_class.create!(code: code, name: 'IUCN Red List')
  end

  describe 'code' do
    it 'has to be unique' do
      platform
      expect(described_class.new(code: 'IUCNRL', name: 'x')).not_to be_valid
    end
  end

  describe 'deletion' do
    # Deleting a platform that still holds rows would orphan them, and they can
    # only come back by re-uploading the file they came from.
    let(:iucn) { platform }
    let(:cites) { described_class.create!(code: 'CITES_EU', name: 'CITES / EU') }

    it 'is allowed when nothing references it' do
      expect(iucn.destroy).to be_truthy
    end

    it 'is refused while it holds names' do
      MappingTaxon.create!(
        matchable_taxonomy: iucn, taxon_nid: '1', accepted_taxon_nid: '1',
        name_status: 'A', scientific_name: 'Panthera leo', source_file: 'f.csv'
      )

      expect(iucn.destroy).to be false
    end

    it 'is refused while matches point at it from the far side' do
      MappingMatch.create!(
        matchable_taxonomy: cites, taxon_nid: '1',
        foreign_matchable_taxonomy: iucn, foreign_taxon_nid: '9',
        matched_name: 'n', matched_name_status: 'A',
        foreign_matched_name: 'n', foreign_matched_name_status: 'A',
        match_confidence: 'high', source_file: 'f.csv'
      )

      expect(iucn.destroy).to be false
    end

    it 'says what is blocking it' do
      MappingTaxon.create!(
        matchable_taxonomy: iucn, taxon_nid: '1', accepted_taxon_nid: '1',
        name_status: 'A', scientific_name: 'Panthera leo', source_file: 'f.csv'
      )
      iucn.destroy

      expect(iucn.errors[:base].join).to include 'taxon names'
    end
  end
end
