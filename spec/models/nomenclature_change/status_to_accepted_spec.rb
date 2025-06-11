require 'spec_helper'

describe NomenclatureChange::StatusToAccepted do
  describe :validate do
    context 'when required primary output missing' do
      context 'when primary_output' do
        let(:status_change) do
          build(
            :nomenclature_change_status_to_accepted,
            status: NomenclatureChange::StatusToAccepted::PRIMARY_OUTPUT
          )
        end
        specify { expect(status_change).to have(1).error_on(:primary_output) }
      end
      context 'when submitting' do
        let(:status_change) do
          build(
            :nomenclature_change_status_to_accepted,
            status: NomenclatureChange::StatusToAccepted::SUBMITTED
          )
        end
        specify { expect(status_change).to have(1).error_on(:primary_output) }
      end
    end
    context 'when primary output has invalid name status' do
      context 'when primary_output' do
        let(:status_change) do
          build(
            :nomenclature_change_status_to_accepted,
            primary_output_attributes: {
              taxon_concept_id: create_cites_eu_species(name_status: 'S').id
            },
            status: NomenclatureChange::StatusToAccepted::PRIMARY_OUTPUT
          )
        end
        specify { expect(status_change.error_on(:primary_output).size).to eq(1) }
      end
    end
    context 'when primary output has valid name status' do
      context 'when primary_output' do
        let(:status_change) do
          build(
            :nomenclature_change_status_to_accepted,
            primary_output_attributes: {
              taxon_concept_id: create_cites_eu_species(name_status: 'T').id
            },
            status: NomenclatureChange::StatusToAccepted::PRIMARY_OUTPUT
          )
        end
        specify { expect(status_change.errors_on(:primary_output).size).to eq(0) }
      end
    end
  end
end
