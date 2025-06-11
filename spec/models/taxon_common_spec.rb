require 'spec_helper'

describe TaxonCommon do
  describe :update do
    let(:language) do
      create(:language)
    end
    let(:parent) do
      create_cites_eu_genus(
        taxon_name: create(:taxon_name, scientific_name: 'Lolcatus')
      )
    end
    let!(:tc) do
      create_cites_eu_species(
        parent_id: parent.id,
        taxon_name: create(:taxon_name, scientific_name: 'lolatus')
      )
    end
    let!(:another_tc) do
      create_cites_eu_species(
        parent_id: parent.id,
        taxon_name: create(:taxon_name, scientific_name: 'lolcatus')
      )
    end
    let(:tc_common) do
      build(
        :taxon_common,
        taxon_concept_id: tc.id,
        name: 'Lolcat',
        language_id: language.id
      )
    end
    context 'when common name changed' do
      let(:another_tc_common) do
        build(
          :taxon_common,
          taxon_concept_id: another_tc.id,
          name: 'Lolcat',
          language_id: language.id
        )
      end
      specify do
        tc_common.save
        another_tc_common.save
        tc_common.name = 'Black lolcat'
        tc_common.save
        expect(another_tc.common_names.map(&:name)).to include('Lolcat')
      end
    end
  end
end
