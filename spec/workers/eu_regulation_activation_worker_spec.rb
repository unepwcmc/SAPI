require 'spec_helper'

describe EuRegulationActivationWorker do
  let(:prev_eu_regulation) {
    create(
      :eu_regulation,
      :name => 'REGULATION 1.0',
      :designation => eu,
      :is_current => true
    )
  }
  let!(:listing_change) {
    create_eu_A_addition(
      :event_id => prev_eu_regulation.id,
      :is_current => true
    )
  }
  let!(:eu_regulation) {
    create_eu_regulation(
      :name => 'REGULATION 2.0',
      :listing_changes_event_id => prev_eu_regulation.id,
      :designation => eu,
      :is_current => false
    )
  }
  describe "Set new EU regulation to true" do
    before do
      EventListingChangesCopyWorker.drain
      EuRegulationActivationWorker.new.perform(eu_regulation.id, true)
    end

    specify { eu_regulation.listing_changes.reload.first.is_current.should be_truthy }
    specify { prev_eu_regulation.listing_changes.reload.first.is_current.should be_truthy }

    describe "Set old EU regulation to false" do
      before do
        EuRegulationActivationWorker.new.perform(prev_eu_regulation.id, false)
      end

      specify { eu_regulation.listing_changes.reload.first.is_current.should be_truthy }
      specify { prev_eu_regulation.listing_changes.reload.first.is_current.should be_falsey }
    end
  end

end
