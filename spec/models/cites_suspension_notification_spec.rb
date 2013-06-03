# == Schema Information
#
# Table name: events
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  designation_id :integer
#  effective_at   :datetime
#  published_at   :datetime
#  description    :text
#  url            :text
#  is_current     :boolean          default(FALSE), not null
#  type           :string(255)      default("Event"), not null
#  legacy_id      :integer
#  end_date       :datetime
#  subtype        :string(255)
#

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
    let(:cites_suspension_notification){ create_cites_suspension_notification(:end_date => '2012-05-10') }
    specify { cites_suspension_notification.end_date_formatted.should == '10/05/2012' }
  end
end
