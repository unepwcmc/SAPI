# == Schema Information
#
# Table name: nomenclature_changes
#
#  id            :integer          not null, primary key
#  event_id      :integer
#  type          :string(255)      not null
#  status        :string(255)      not null
#  created_by_id :integer          not null
#  updated_by_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe NomenclatureChange::Lump do
  describe :validate do
    context "when required inputs missing" do
      context "when inputs" do
        let(:lump) {
          build(
            :nomenclature_change_lump, :status => NomenclatureChange::Lump::INPUTS
          )
        }
        specify { expect(lump).to have(1).errors_on(:inputs) }
      end
      context "when submitting" do
        let(:lump) {
          build(
            :nomenclature_change_lump, :status => NomenclatureChange::Lump::SUBMITTED
          )
        }
        specify { expect(lump).to have(1).errors_on(:inputs) }
      end
    end
    context "when required outputs missing" do
      context "when outputs" do
        let(:lump) {
          build(
            :nomenclature_change_lump, :status => NomenclatureChange::Lump::OUTPUTS
          )
        }
        specify { expect(lump).to have(1).errors_on(:output) }
      end
      context "when submitting" do
        let(:lump) {
          build(
            :nomenclature_change_lump, :status => NomenclatureChange::Lump::SUBMITTED
          )
        }
        specify { expect(lump).to have(1).errors_on(:output) }
      end
      context "when only 1 input" do
        let(:lump) {
          build(
            :nomenclature_change_lump, :status => NomenclatureChange::Lump::SUBMITTED,
            :inputs_attributes => { 0 => { :taxon_concept_id => create_cites_eu_subspecies.id } }
          )
        }
        specify { expect(lump).to have(1).errors_on(:inputs) }
      end
    end
  end
  describe :new_output_rank do
    let(:lump) {
      build(
        :nomenclature_change_lump,
        inputs_attributes: {
          0 => { taxon_concept_id: create_cites_eu_species.id },
          1 => { taxon_concept_id: create_cites_eu_subspecies.id }
        },
        status: NomenclatureChange::Lump::INPUTS
      )
    }
    specify { expect(lump.new_output_rank.name).to eq(Rank::SPECIES) }
  end
end
