# == Schema Information
#
# Table name: nomenclature_changes
#
#  id            :integer          not null, primary key
#  status        :string(255)      not null
#  type          :string(255)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :integer          not null
#  event_id      :integer
#  updated_by_id :integer          not null
#
# Foreign Keys
#
#  nomenclature_changes_created_by_id_fk  (created_by_id => users.id)
#  nomenclature_changes_event_id_fk       (event_id => events.id)
#  nomenclature_changes_updated_by_id_fk  (updated_by_id => users.id)
#

require 'spec_helper'

describe NomenclatureChange::Split do
  describe :validate do
    context "when required inputs missing" do
      context "when inputs" do
        let(:split) {
          build(
            :nomenclature_change_split, status: NomenclatureChange::Split::INPUTS
          )
        }
        specify { expect(split).to have(1).errors_on(:input) }
      end
      context "when submitting" do
        let(:split) {
          build(
            :nomenclature_change_split, status: NomenclatureChange::Split::SUBMITTED
          )
        }
        specify { expect(split).to have(1).errors_on(:input) }
      end
    end
    context "when required outputs missing" do
      context "when outputs" do
        let(:split) {
          build(
            :nomenclature_change_split, status: NomenclatureChange::Split::OUTPUTS
          )
        }
        specify { expect(split).to have(1).errors_on(:outputs) }
      end
      context "when submitting" do
        let(:split) {
          build(
            :nomenclature_change_split, status: NomenclatureChange::Split::SUBMITTED
          )
        }
        specify { expect(split).to have(1).errors_on(:outputs) }
      end
    end
    context "when output has different rank than input" do
      let(:split) {
        build(:nomenclature_change_split,
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
      }
      specify { expect(split.errors_on(:outputs).size).to eq(1) }
    end
  end
end
