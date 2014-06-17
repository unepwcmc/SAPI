require 'spec_helper'

describe NomenclatureChange::Split::Processor do
  describe :run do
    let(:input_species){ create_cites_eu_species }
    let(:output_species1){ create_cites_eu_species }
    let(:output_species2){ create_cites_eu_species }
    context "when outputs are existing taxa" do
      let!(:split){
        s = create(:nomenclature_change_split)
        s.update_attributes(
          :input_attributes => {:taxon_concept_id => input_species.id},
          :status => NomenclatureChange::Split::INPUTS
        )
        s.update_attributes(
          :outputs_attributes => {
            0 => { :taxon_concept_id => output_species1.id },
            1 => { :taxon_concept_id => output_species2.id }
          },
          :status => NomenclatureChange::Split::OUTPUTS
        )
        s
      }
      specify { expect{ split.submit }.not_to change(TaxonConcept, :count) }
      specify { expect{ split.submit }.not_to change(output_species1, :full_name) }
      specify { expect{ split.submit }.not_to change(output_species2, :full_name) }
    end
    context "when output is new taxon" do
      let(:output_species2_attrs){
        {
          :new_scientific_name => 'fatalus',
          :new_parent_id => create_cites_eu_genus.id,
          :new_rank_id => species_rank.id,
          :new_name_status => 'A'
        }
      }
      let!(:split){
        s = create(:nomenclature_change_split)
        s.update_attributes(
          :input_attributes => {:taxon_concept_id => input_species.id},
          :status => NomenclatureChange::Split::INPUTS
        )
        s.update_attributes(
          :outputs_attributes => {
            0 => { :taxon_concept_id => output_species1},
            1 => output_species2_attrs
          },
          :status => NomenclatureChange::Split::OUTPUTS
        )
        s
      }
      specify { expect{ split.submit }.to change(TaxonConcept, :count).by(1) }
    end
    context "when output is existing taxon with new status" do
      let(:output_species2){ create_cites_eu_species(:name_status => 'S') }
      let!(:split){
        s = create(:nomenclature_change_split)
        s.update_attributes(
          :input_attributes => {:taxon_concept_id => input_species.id},
          :status => NomenclatureChange::Split::INPUTS
        )
        s.update_attributes(
          :outputs_attributes => {
            0 => { :taxon_concept_id => output_species1},
            1 => { :taxon_concept_id => output_species2.id, :new_name_status => 'A' }
          },
          :status => NomenclatureChange::Split::OUTPUTS
        )
        s
      }
      specify { expect{ split.submit }.not_to change(TaxonConcept, :count) }
      specify { expect{ split.submit }.not_to change(output_species1, :full_name) }
      specify { expect{ split.submit }.not_to change(output_species2, :full_name) }
    end
    context "when output is existing taxon with new name" do
      let(:output_subspecies2){ create_cites_eu_subspecies }
      let(:output_species2_attrs){
        a = {
          :taxon_concept_id => output_subspecies2.id,
          :new_scientific_name => 'lolcatus',
          :new_rank_id => species_rank.id
        }
        a
      }
      let!(:split){
        s = create(:nomenclature_change_split)
        s.update_attributes(
          :input_attributes => {:taxon_concept_id => input_species.id},
          :status => NomenclatureChange::Split::INPUTS
        )
        s.update_attributes(
          :outputs_attributes => {
            0 => { :taxon_concept_id => output_species1.id},
            1 => output_species2_attrs
          },
          :status => NomenclatureChange::Split::OUTPUTS
        )
        s
      }
      specify { expect{ split.submit }.to change(TaxonConcept, :count).by(1) }
      specify { expect{ split.submit }.not_to change(output_species1, :full_name) }
      specify { expect{ split.submit }.not_to change(output_subspecies2, :full_name) }
    end
  end
end