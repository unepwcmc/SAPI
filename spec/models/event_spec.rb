# == Schema Information
#
# Table name: events
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  designation_id       :integer
#  description          :text
#  url                  :text
#  is_current           :boolean          default(FALSE), not null
#  type                 :string(255)      default("Event"), not null
#  effective_at         :datetime
#  published_at         :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  legacy_id            :integer
#  end_date             :datetime
#  subtype              :string(255)
#  updated_by_id        :integer
#  created_by_id        :integer
#  extended_description :text
#  multilingual_url     :text
#  elib_legacy_id       :integer
#

require 'spec_helper'

describe Event do
  describe :create do
    context "when valid" do
      let(:event) { build(:event, :name => 'CoPX') }
      specify { event.should be_valid }
    end
    context "when name missing" do
      let(:event) { build(:event, :name => nil) }
      specify { event.should be_invalid }
      specify { event.should have(1).error_on(:name) }
    end
    context "when name duplicated" do
      let!(:event1) { create(:event) }
      let(:event2) { build(:event, :name => event1.name) }
      specify { event2.should be_invalid }
      specify { event2.should have(1).error_on(:name) }
    end
    context "when url invalid" do
      let(:event) { build(:event, :url => 'www.google.com') }
      specify { event.should be_invalid }
      specify { event.should have(1).error_on(:url) }
    end
  end

  describe :effective_at_formatted do
    let(:event) { create(:event, :effective_at => '2012-05-10') }
    specify { event.effective_at_formatted.should == '10/05/2012' }
  end
end
