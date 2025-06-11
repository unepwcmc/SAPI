require 'spec_helper'

describe NomenclatureChange::Split do
  describe :validate do
    context 'when required inputs missing' do
      context 'when inputs' do
        let(:split) do
          build(
            :nomenclature_change_split, status: NomenclatureChange::Split::INPUTS
          )
        end
        specify { expect(split).to have(1).errors_on(:input) }
      end
      context 'when submitting' do
        let(:split) do
          build(
            :nomenclature_change_split, status: NomenclatureChange::Split::SUBMITTED
          )
        end
        specify { expect(split).to have(1).errors_on(:input) }
      end
    end
    context 'when required outputs missing' do
      context 'when outputs' do
        let(:split) do
          build(
            :nomenclature_change_split, status: NomenclatureChange::Split::OUTPUTS
          )
        end
        specify { expect(split).to have(1).errors_on(:outputs) }
      end
      context 'when submitting' do
        let(:split) do
          build(
            :nomenclature_change_split, status: NomenclatureChange::Split::SUBMITTED
          )
        end
        specify { expect(split).to have(1).errors_on(:outputs) }
      end
    end
    context 'when output has different rank than input' do
      let(:split) do
        build(
          :nomenclature_change_split,
          status: NomenclatureChange::Split::OUTPUTS,
          input_attributes: { taxon_concept_id: create_cites_eu_species.id },
          outputs_attributes: {
            0 => {
              taxon_concept_id: create_cites_eu_subspecies.id,
              new_rank_id: create(:rank, name: Rank::SUBSPECIES).id
            },
            1 => {
              taxon_concept_id: create_cites_eu_subspecies.id,
              new_rank_id: create(:rank, name: Rank::SUBSPECIES).id
            }
          }
        )
      end
      specify { expect(split.errors_on(:outputs).size).to eq(1) }
    end
  end
end
