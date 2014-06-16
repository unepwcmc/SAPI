require 'spec_helper'

describe NomenclatureChange::Split::Processor do
  describe :run do
    context "when outputs are existing taxa" do
      let!(:split){
        s = create(:nomenclature_change_split)
        s.update_attributes(
          :input_attributes => {:taxon_concept_id => create_cites_eu_species.id},
          :status => NomenclatureChange::Split::INPUTS
        )
        s.update_attributes(
          :outputs_attributes => {
            0 => { :taxon_concept_id => create_cites_eu_species.id },
            1 => { :taxon_concept_id => create_cites_eu_species.id }
          },
          :status => NomenclatureChange::Split::OUTPUTS
        )
        s
      }
      specify { expect{ split.submit }.not_to change{ TaxonConcept.count } }
    end
    context "when output is new taxon" do
      let(:output_parent){ create_cites_eu_genus }
      let!(:split){
        s = create(:nomenclature_change_split)
        s.update_attributes(
          :input_attributes => {:taxon_concept_id => create_cites_eu_species.id},
          :status => NomenclatureChange::Split::INPUTS
        )
        s.update_attributes(
          :outputs_attributes => {
            0 => { :taxon_concept_id => create_cites_eu_species.id},
            1 => {
              :new_scientific_name => 'fatalus',
              :new_parent_id => output_parent.id,
              :new_rank_id => species_rank.id,
              :new_name_status => 'A'
            }
          },
          :status => NomenclatureChange::Split::OUTPUTS
        )
        s
      }
      specify { expect{ split.submit }.to change{ TaxonConcept.count }.by(1) }
    end
    context "when output is existing taxon with new status" do
      let(:output_species){ create_cites_eu_species(:name_status => 'S') }
      let!(:split){
        s = create(:nomenclature_change_split)
        s.update_attributes(
          :input_attributes => {:taxon_concept_id => create_cites_eu_species.id},
          :status => NomenclatureChange::Split::INPUTS
        )
        s.update_attributes(
          :outputs_attributes => {
            0 => { :taxon_concept_id => create_cites_eu_species.id},
            1 => { :taxon_concept_id => output_species.id, :new_name_status => 'A' }
          },
          :status => NomenclatureChange::Split::OUTPUTS
        )
        s
      }
      specify { expect{ split.submit }.not_to change{ TaxonConcept.count } }
    end
    pending "when output is existing taxon with new name" do
      let(:output_subspecies){ create_cites_eu_subspecies }
      let!(:split){
        s = create(:nomenclature_change_split)
        s.update_attributes(
          :input_attributes => {:taxon_concept_id => create_cites_eu_species.id},
          :status => NomenclatureChange::Split::INPUTS
        )
        s.update_attributes(
          :outputs_attributes => {
            0 => { :taxon_concept_id => create_cites_eu_species.id},
            1 => {
              :taxon_concept_id => output_subspecies.id,
              :new_rank_id => species_rank.id,
              :new_scientific_name => 'Lolcatus'
            }
          },
          :status => NomenclatureChange::Split::OUTPUTS
        )
        s
      }
      specify { expect{ split.save }.to change{ TaxonConcept.count }.by(2) }
    end
  end
end