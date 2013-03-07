require 'spec_helper'

describe EventActivationWorker do
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
  let!(:eu_regulation){
    create(
      :eu_regulation,
      :name => 'REGULATION 2.0',
      :listing_changes_event_id => prev_eu_regulation.id,
      :designation_id => prev_eu_regulation.designation_id,
      :is_current => false
    )
  }
  before do
    EventListingChangesCopyWorker.drain
    EventActivationWorker.new.perform(eu_regulation.id)
  end
  specify { prev_eu_regulation.reload.is_current.should be_false }
  specify { eu_regulation.listing_changes.reload.first.is_current.should be_true }
end