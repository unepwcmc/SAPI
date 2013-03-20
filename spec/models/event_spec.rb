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
#

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
    context "when url invalid" do
      let(:event){ build(:event, :url => 'www.google.com') }
      specify { event.should be_invalid}
      specify { event.should have(1).error_on(:url) }
    end
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
