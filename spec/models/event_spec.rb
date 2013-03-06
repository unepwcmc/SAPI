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
  describe :destroy do
    context "when no dependent objects attached" do
      let(:event){ create(:event, :name => 'REGULATION 1.0') }
      specify { event.destroy.should be_true }
    end
    context "when dependent objects attached" do
      let(:event){ create(:event, :name => 'REGULATION 1.0') }
      let!(:listing_change){ create(:cites_I_addition, :event_id => event.id)}
      specify { event.destroy.should be_false }
    end
  end
end
