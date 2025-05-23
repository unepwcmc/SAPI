require 'spec_helper'

describe EuRegulationActivationWorker do
  let(:prev_eu_regulation) do
    create(
      :eu_regulation,
      name: 'REGULATION 1.0',
      designation: eu,
      is_current: true
    )
  end
  let!(:listing_change) do
    create_eu_A_addition(
      event_id: prev_eu_regulation.id,
      is_current: true
    )
  end
  let!(:eu_regulation) do
    create_eu_regulation(
      name: 'REGULATION 2.0',
      listing_changes_event_id: prev_eu_regulation.id,
      designation: eu,
      is_current: false
    )
  end
  describe 'Set new EU regulation to true' do
    before do
      EventListingChangesCopyWorker.drain
      EuRegulationActivationWorker.new.perform(eu_regulation.id, true)
    end

    specify { expect(eu_regulation.listing_changes.reload.first.is_current).to be_truthy }
    specify { expect(prev_eu_regulation.listing_changes.reload.first.is_current).to be_truthy }

    describe 'Set old EU regulation to false' do
      before do
        EuRegulationActivationWorker.new.perform(prev_eu_regulation.id, false)
      end

      specify { expect(eu_regulation.listing_changes.reload.first.is_current).to be_truthy }
      specify { expect(prev_eu_regulation.listing_changes.reload.first.is_current).to be_falsey }
    end
  end
end
