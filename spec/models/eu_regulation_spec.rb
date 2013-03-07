require 'spec_helper'

describe EuRegulation do
  describe :create do
    context "when eu_regulation to copy from given" do
      let(:eu_regulation1){ create(:eu_regulation) }
      before do
        EventListingChangesCopyWorker.jobs.clear
        create(:eu_regulation, :listing_changes_event_id => eu_regulation1.id)
      end
      specify{ EventListingChangesCopyWorker.jobs.size.should == 1 }
    end
  end
  describe :can_be_activated? do
    let(:eu_regulation){
      create(
        :eu_regulation,
        :designation => Designation.find_or_create_by_name('EU'),
        :is_current => false,
        :effective_at => '2012-05-01'
      )
    }
    context "when no other eu_regulations" do
      specify{ eu_regulation.can_be_activated?.should be_true }
    end
    context "when current eu_regulation is later" do
      let!(:other_eu_regulation){
        create(
          :eu_regulation, :designation => Designation.find_or_create_by_name('EU'),
          :is_current => true, :effective_at => '2012-05-10'
        )
      }
      specify{ eu_regulation.can_be_activated?.should be_false }
    end
    context "when current eu_regulation is earlier" do
      let!(:other_eu_regulation){
        create(
          :eu_regulation, :designation => Designation.find_or_create_by_name('EU'),
          :is_current => true, :effective_at => '2012-04-10'
        )
      }
      specify{ eu_regulation.can_be_activated?.should be_true }
    end
  end
  describe :activate do
    let(:prev_eu_regulation){ create(:eu_regulation, :name => 'REGULATION 1.0', :is_current => true) }
    let(:eu_regulation){ create(:eu_regulation, :name => 'REGULATION 2.0') }
    before do
      EventActivationWorker.jobs.clear
      eu_regulation.activate!
    end
    specify{ eu_regulation.is_current.should be_true }
    specify{ EventActivationWorker.jobs.size.should == 1 }
  end
end
