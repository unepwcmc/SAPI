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

describe NomenclatureChange::StatusToSynonym do
  describe :validate do
    context "when required primary output missing" do
      context "when primary_output" do
        let(:status_change) {
          build(
            :nomenclature_change_status_to_synonym,
            status: NomenclatureChange::StatusToSynonym::PRIMARY_OUTPUT
          )
        }
        specify { expect(status_change).to have(1).error_on(:primary_output) }
      end
      context "when submitting" do
        let(:status_change) {
          build(
            :nomenclature_change_status_to_synonym,
            status: NomenclatureChange::StatusToSynonym::SUBMITTED
          )
        }
        specify { expect(status_change).to have(1).error_on(:primary_output) }
      end
    end
    context "when primary output has invalid name status" do
      context "when primary_output" do
        let(:status_change) {
          build(
            :nomenclature_change_status_to_synonym,
            primary_output_attributes: {
              taxon_concept_id: create_cites_eu_species(name_status: 'A').id
            },
            status: NomenclatureChange::StatusToAccepted::PRIMARY_OUTPUT
          )
        }
        specify { expect(status_change.error_on(:primary_output).size).to eq(1) }
      end
    end
    context "when primary output has valid name status" do
      context "when primary_output" do
        let(:status_change) {
          build(
            :nomenclature_change_status_to_synonym,
            primary_output_attributes: {
              taxon_concept_id: create_cites_eu_species(name_status: 'N').id
            },
            status: NomenclatureChange::StatusToAccepted::PRIMARY_OUTPUT
          )
        }
        specify { expect(status_change.errors_on(:primary_output).size).to eq(0) }
      end
    end
    context "when required secondary output missing" do
      context "when relay" do
        let(:status_change) {
          build(
            :nomenclature_change_status_to_synonym,
            primary_output_attributes: { taxon_concept_id: create_cites_eu_species(name_status: 'N').id },
            status: NomenclatureChange::StatusToSynonym::RELAY
          )
        }
        specify { expect(status_change.error_on(:secondary_output).size).to eq(1) }
      end
      context "when submitting" do
        let(:status_change) {
          build(
            :nomenclature_change_status_to_synonym,
            primary_output_attributes: { taxon_concept_id: create_cites_eu_species(name_status: 'N').id },
            status: NomenclatureChange::StatusToSynonym::SUBMITTED
          )
        }
        specify { expect(status_change.error_on(:secondary_output).size).to eq(1) }
      end
    end
  end
end
