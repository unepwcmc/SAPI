require 'spec_helper'

describe Event do
  describe :create do
    context "when valid" do
      let(:event){ build(:event, :name => 'CoPX') }
      specify {event.should be_valid}
    end
    context "when name missing" do
      let(:event){ build(:event, :name => nil) }
      specify { event.should be_invalid}
      specify { event.should have(1).error_on(:name) }
    end
    context "when name duplicated" do
      let!(:event1){ create(:event) }
      let(:event2){ build(:event, :name => event1.name) }
      specify { event2.should be_invalid }
      specify { event2.should have(1).error_on(:name) }
    end
    context "when event to copy from given" do
      let(:event1){ create(:event) }
      before do
        EventListingChangesCopyWorker.jobs.clear
        create(:event, :listing_changes_event_id => event1.id)
      end
      specify{ EventListingChangesCopyWorker.jobs.size.should == 1 }
    end
  end
  describe :can_be_activated? do
    let(:event){
      create(
        :event,
        :designation => Designation.find_or_create_by_name('EU'),
        :is_current => false,
        :effective_at => '2012-05-01'
      )
    }
    context "when non-eu" do
      let(:event){
        create(:event, :designation => create(:designation, :name => 'ZONK'))
      }
      specify{ event.can_be_activated?.should be_false }
    end
    context "when no other events" do
      specify{ event.can_be_activated?.should be_true }
    end
    context "when current event is later" do
      let!(:other_event){
        create(
          :event, :designation => Designation.find_or_create_by_name('EU'),
          :is_current => true, :effective_at => '2012-05-10'
        )
      }
      specify{ event.can_be_activated?.should be_false }
    end
    context "when current event is earlier" do
      let!(:other_event){
        create(
          :event, :designation => Designation.find_or_create_by_name('EU'),
          :is_current => true, :effective_at => '2012-04-10'
        )
      }
      specify{ event.can_be_activated?.should be_true }
    end
  end
  describe :activate do
    let(:prev_event){ create(:event, :name => 'REGULATION 1.0', :is_current => true) }
    let(:event){ create(:event, :name => 'REGULATION 2.0') }
    before do
      EventActivationWorker.jobs.clear
      event.activate!
    end
    specify{ event.is_current.should be_true }
    specify{ EventActivationWorker.jobs.size.should == 1 }
  end
  describe :destroy do
    context "when no dependent objects attached" do
      let(:event){
        create(
          :event,
          :name => 'REGULATION 1.0',
          :designation => Designation.find_or_create_by_name('EU')
        )
      }
      specify { event.destroy.should be_true }
    end
    context "when dependent objects attached" do
      let(:event){
        create(
          :event,
          :name => 'REGULATION 1.0',
          :designation => Designation.find_or_create_by_name('EU')
        )
      }
      let!(:listing_change){ create(:eu_A_addition, :event_id => event.id)}
      specify { event.destroy.should be_false }
    end
  end
  describe :effective_at_formatted do
    let(:event){ create(:event, :effective_at => '2012-05-10') }
    specify {event.effective_at_formatted.should == '10/05/2012' }
  end
end
