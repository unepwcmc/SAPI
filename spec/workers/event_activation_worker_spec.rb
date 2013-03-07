require 'spec_helper'

describe EventActivationWorker do
  let(:prev_event){
    create(
      :event,
      :name => 'REGULATION 1.0',
      :designation => Designation.find_or_create_by_name('EU'),
      :is_current => true
    )
  }
  let!(:listing_change){
    create(
      :eu_A_addition,
      :event_id => prev_event.id
    )
  }
  let!(:event){
    create(
      :event,
      :name => 'REGULATION 2.0',
      :listing_changes_event_id => prev_event.id,
      :designation_id => prev_event.designation_id,
      :is_current => false
    )
  }
  before do
    EventListingChangesCopyWorker.drain
    EventActivationWorker.new.perform(event.id)
  end
  specify { prev_event.reload.is_current.should be_false }
  specify { event.listing_changes.reload.first.is_current.should be_true }
end