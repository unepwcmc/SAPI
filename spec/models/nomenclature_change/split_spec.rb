require 'spec_helper'

describe NomenclatureChange::Split do
  describe :validate do
    context "when required inputs missing" do
      context "when inputs" do
        let(:split){
          build(
            :nomenclature_change_split, :status => NomenclatureChange::Split::INPUTS
          )
        }
        specify { expect(split).to have(1).errors_on(:input) }
      end
      context "when submitting" do
        let(:split){
          build(
            :nomenclature_change_split, :status => NomenclatureChange::Split::SUBMITTED
          )
        }
        specify { expect(split).to have(1).errors_on(:input) }
      end
    end
    context "when required outputs missing" do
      context "when outputs" do
        let(:split){
          build(
            :nomenclature_change_split, :status => NomenclatureChange::Split::OUTPUTS
          )
        }
        specify { expect(split).to have(1).errors_on(:outputs) }
      end
      context "when submitting" do
        let(:split){
          build(
            :nomenclature_change_split, :status => NomenclatureChange::Split::SUBMITTED
          )
        }
        specify { expect(split).to have(1).errors_on(:outputs) }
      end
    end
    context "when output has different rank than input" do
      context "new rank not specified" do
        let(:split){
          build(:nomenclature_change_split, :status => NomenclatureChange::Split::OUTPUTS,
            :input_attributes => {:taxon_concept_id => create_cites_eu_species.id},
            :outputs_attributes => {
              0 => {:taxon_concept_id => create_cites_eu_subspecies.id}
            }
          )
        }
        specify { expect(split).to have(1).errors_on(:outputs) }
      end
      context "incorrect new rank specified" do
        let(:split){
          build(:nomenclature_change_split, :status => NomenclatureChange::Split::OUTPUTS,
            :input_attributes => {:taxon_concept_id => create_cites_eu_genus.id},
            :outputs_attributes => {
              0 => {
                :taxon_concept_id => create_cites_eu_subspecies.id,
                :new_rank_id => species_rank.id
              }
            }
          )
        }
        specify { expect(split).to have(1).errors_on(:outputs) }
      end
    end
  end
end