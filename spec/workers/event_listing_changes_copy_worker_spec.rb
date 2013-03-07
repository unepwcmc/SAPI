require 'spec_helper'

describe EventListingChangesCopyWorker do
  let(:prev_eu_regulation){
    create(
      :eu_regulation,
      :name => 'REGULATION 1.0',
      :designation => Designation.find_or_create_by_name('EU'),
      :is_current => true
    )
  }
  let!(:listing_change){
    create(
      :eu_A_addition,
      :event_id => prev_eu_regulation.id
    )
  }
  let(:eu_regulation){
    create(
      :eu_regulation,
      :name => 'REGULATION 2.0',
      :listing_changes_event_id => prev_eu_regulation.id,
      :designation_id => prev_eu_regulation.designation_id,
      :is_current => false
    )
  }
  before { EventListingChangesCopyWorker.new.perform(prev_eu_regulation.id, eu_regulation.id) }
  specify { eu_regulation.listing_changes.reload.count.should == 1 }
end