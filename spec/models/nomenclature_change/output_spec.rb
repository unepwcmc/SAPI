# == Schema Information
#
# Table name: nomenclature_change_outputs
#
#  id                     :integer          not null, primary key
#  author_year            :string(255)
#  internal_note          :text             default("")
#  is_primary_output      :boolean          default(TRUE)
#  name_status            :string(255)
#  new_author_year        :string(255)
#  new_name_status        :string(255)
#  new_scientific_name    :string(255)
#  note_en                :text             default("")
#  note_es                :text             default("")
#  note_fr                :text             default("")
#  scientific_name        :string(255)
#  tag_list               :text             default("--- []\n")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  created_by_id          :integer          not null
#  new_parent_id          :integer
#  new_rank_id            :integer
#  new_taxon_concept_id   :integer
#  nomenclature_change_id :integer          not null
#  parent_id              :integer
#  rank_id                :integer
#  taxon_concept_id       :integer
#  taxonomy_id            :integer
#  updated_by_id          :integer          not null
#
# Foreign Keys
#
#  nomenclature_change_outputs_created_by_id_fk           (created_by_id => users.id)
#  nomenclature_change_outputs_new_parent_id_fk           (new_parent_id => taxon_concepts.id)
#  nomenclature_change_outputs_new_rank_id_fk             (new_rank_id => ranks.id)
#  nomenclature_change_outputs_new_taxon_concept_id_fk    (new_taxon_concept_id => taxon_concepts.id)
#  nomenclature_change_outputs_nomenclature_change_id_fk  (nomenclature_change_id => nomenclature_changes.id)
#  nomenclature_change_outputs_taxon_concept_id_fk        (taxon_concept_id => taxon_concepts.id)
#  nomenclature_change_outputs_updated_by_id_fk           (updated_by_id => users.id)
#

require 'spec_helper'

describe NomenclatureChange::Output do
  before(:each) { cites_eu }
  describe :validate do
    context 'when nomenclature change not specified' do
      let(:output) do
        build(:nomenclature_change_output, nomenclature_change_id: nil)
      end
      specify { expect(output).not_to be_valid }
    end
    context 'when taxon concept not specified and new taxon concept attributes not specified' do
      let(:output) do
        build(
          :nomenclature_change_output, taxon_concept_id: nil,
          new_scientific_name: nil,
          new_parent_id: nil,
          new_rank_id: nil,
          new_name_status: nil
        )
      end
      specify { expect(output).to have(1).errors_on(:new_scientific_name) }
      specify { expect(output).to have(1).errors_on(:new_parent_id) }
      specify { expect(output).to have(1).errors_on(:new_rank) }
      specify { expect(output).to have(1).errors_on(:new_name_status) }
      specify { expect(output).to have(1).errors_on(:new_taxon_concept) }
    end
    context 'when new taxon concept invalid' do
      let(:output) do
        build(
          :nomenclature_change_output, taxon_concept_id: nil,
          new_scientific_name: 'xxx',
          new_parent_id: create_cites_eu_species.id,
          new_rank_id: create(:rank, name: Rank::SPECIES).id,
          new_name_status: 'A'
        )
      end
      specify { expect(output.error_on(:new_parent_id).size).to eq(1) }
    end
    context 'when taxon concept specified' do
      let(:tc) { create_cites_eu_species }
      let(:output) do
        create(:nomenclature_change_output, taxon_concept_id: tc.id)
      end
      specify { expect(output.parent_id).to eq(tc.parent_id) }
      specify { expect(output.rank_id).to eq(tc.rank_id) }
      specify { expect(output.scientific_name).to eq(tc.full_name) }
      specify { expect(output.author_year).to eq(tc.author_year) }
      specify { expect(output.name_status).to eq(tc.name_status) }
    end
  end
  describe :expected_parent_name do
    let(:output) do
      create(:nomenclature_change_output, taxon_concept_id: tc.id)
    end
    let(:canis_genus) do
      create_cites_eu_genus(
        taxon_name: create(:taxon_name, scientific_name: 'Canis')
      )
    end
    let(:canis_species) do
      create_cites_eu_species(
        taxon_name: create(:taxon_name, scientific_name: 'lupus'),
        parent: canis_genus
      )
    end
    let(:canis_subspecies) do
      create_cites_eu_subspecies(
        taxon_name: create(:taxon_name, scientific_name: 'dingo'),
        parent: canis_species
      )
    end
    let(:magnolia_genus) do
      create_cites_eu_genus(
        taxon_name: create(:taxon_name, scientific_name: 'Magnolia')
      )
    end
    let(:magnolia_species) do
      create_cites_eu_species(
        taxon_name: create(:taxon_name, scientific_name: 'liliifera'),
        parent: magnolia_genus
      )
    end
    let(:magnolia_variety) do
      create_cites_eu_variety(
        taxon_name: create(:taxon_name, scientific_name: 'var. obovata'),
        parent: magnolia_species
      )
    end
    context 'when genus' do
      let(:tc) { canis_genus }
      specify { expect(output.expected_parent_name).to be_nil }
    end
    context 'when species' do
      let(:tc) { canis_species }
      specify { expect(output.expected_parent_name).to eq('Canis') }
    end
    context 'when subspecies' do
      let(:tc) { canis_subspecies }
      specify { expect(output.expected_parent_name).to eq('Canis lupus') }
    end
    context 'when variety' do
      let(:tc) { magnolia_variety }
      specify { expect(output.expected_parent_name).to eq('Magnolia liliifera') }
    end
  end
end
