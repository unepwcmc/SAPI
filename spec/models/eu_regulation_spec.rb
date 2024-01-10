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

describe EuRegulation do
  describe :create do
    context "when eu_regulation to copy from given" do
      let(:eu_regulation1) { create_eu_regulation }
      before do
        EventListingChangesCopyWorker.jobs.clear
        create_eu_regulation(:listing_changes_event_id => eu_regulation1.id)
      end
      specify { EventListingChangesCopyWorker.jobs.size.should == 1 }
    end
    context "when designation invalid" do
      let(:eu_regulation) {
        build(
          :eu_regulation,
          :designation => cites
        )
      }
      specify { eu_regulation.should be_invalid }
      specify { eu_regulation.should have(1).error_on(:designation_id) }
    end
    context "when effective_at is blank" do
      let(:eu_regulation) {
        build(
          :eu_regulation,
          :effective_at => nil
        )
      }
      specify { eu_regulation.should be_invalid }
      specify { eu_regulation.should have(1).error_on(:effective_at) }
    end
  end
  describe :activate do
    let(:eu_regulation) { create_eu_regulation(:name => 'REGULATION 2.0') }
    before do
      EuRegulationActivationWorker.jobs.clear
      eu_regulation.activate!
    end
    specify { eu_regulation.is_current.should be_truthy }
    specify { EuRegulationActivationWorker.jobs.size.should == 1 }
  end

  describe :deactivate do
    let(:eu_regulation) { create_eu_regulation(:name => 'REGULATION 2.0', :is_current => true) }
    before do
      EuRegulationActivationWorker.jobs.clear
      eu_regulation.deactivate!
    end
    specify { eu_regulation.is_current.should be_falsey }
    specify { EuRegulationActivationWorker.jobs.size.should == 1 }
  end

  describe :destroy do
    let(:eu_regulation) { create_eu_regulation }
    context "when no dependent objects attached" do
      specify { eu_regulation.destroy.should be_truthy }
    end
    context "when dependent objects attached" do
      context "when listing changes" do
        let!(:listing_change) { create_eu_A_addition(:event => eu_regulation) }
        specify { eu_regulation.destroy.should be_truthy }
      end
    end
  end

end
