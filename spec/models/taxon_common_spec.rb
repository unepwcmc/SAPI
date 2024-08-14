# == Schema Information
#
# Table name: taxon_commons
#
#  id               :integer          not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  common_name_id   :integer          not null
#  created_by_id    :integer
#  taxon_concept_id :integer          not null
#  updated_by_id    :integer
#
# Foreign Keys
#
#  taxon_commons_common_name_id_fk    (common_name_id => common_names.id)
#  taxon_commons_created_by_id_fk     (created_by_id => users.id)
#  taxon_commons_taxon_concept_id_fk  (taxon_concept_id => taxon_concepts.id)
#  taxon_commons_updated_by_id_fk     (updated_by_id => users.id)
#

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
