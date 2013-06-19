require 'spec_helper'

describe EventListingChangesCopyWorker do
  let(:prev_eu_regulation){
    create_eu_regulation(
      :name => 'REGULATION 1.0',
      :designation => eu,
      :is_current => true
    )
  }
  let!(:listing_change){
    create_eu_A_addition(
      :event_id => prev_eu_regulation.id
    )
  }
  let(:eu_regulation){
    create_eu_regulation(
      :name => 'REGULATION 2.0',
      :listing_changes_event_id => prev_eu_regulation.id,
      :designation => eu,
      :is_current => false
    )
  }
  before { EventListingChangesCopyWorker.new.perform(prev_eu_regulation.id, eu_regulation.id) }
  specify { eu_regulation.listing_changes.reload.count.should == 1 }
end