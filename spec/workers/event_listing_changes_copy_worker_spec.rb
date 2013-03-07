require 'spec_helper'

describe EventListingChangesCopyWorker do
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
  let(:event){
    create(
      :event,
      :name => 'REGULATION 2.0',
      :listing_changes_event_id => prev_event.id,
      :designation_id => prev_event.designation_id,
      :is_current => false
    )
  }
  before { EventListingChangesCopyWorker.new.perform(prev_event.id, event.id) }
  specify { event.listing_changes.reload.count.should == 1 }
end