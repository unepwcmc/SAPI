require 'spec_helper'

describe CitesSuspensionNotification do
  describe :create do
    context "when designation invalid" do
      let(:cites_suspension_notification){
        build(
          :cites_suspension_notification,
          :designation => eu
        )
      }
      specify { cites_suspension_notification.should be_invalid}
      specify { cites_suspension_notification.should have(1).error_on(:designation_id) }
    end
    context "when effective_at is blank" do
      let(:cites_suspension_notification){
        build(
          :cites_suspension_notification,
          :effective_at => nil
        )
      }
      specify { cites_suspension_notification.should be_invalid}
      specify { cites_suspension_notification.should have(1).error_on(:effective_at) }
    end
  end

  describe :end_date_formatted do
    let(:cites_suspension_notification){ create(:cites_supension_notification, :end_date => '2012-05-10') }
    specify {event.end_date_formatted.should == '10/05/2012' }
  end
end
