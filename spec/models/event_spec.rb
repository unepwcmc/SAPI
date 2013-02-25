# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
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
  end
end
