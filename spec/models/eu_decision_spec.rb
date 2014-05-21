# == Schema Information
#
# Table name: eu_decisions
#
#  id                  :integer          not null, primary key
#  is_current          :boolean          default(TRUE)
#  notes               :text
#  internal_notes      :text
#  taxon_concept_id    :integer
#  geo_entity_id       :integer
#  start_date          :datetime
#  start_event_id      :integer
#  end_date            :datetime
#  end_event_id        :integer
#  type                :string(255)
#  conditions_apply    :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  eu_decision_type_id :integer
#  term_id             :integer
#  source_id           :integer
#  created_by_id       :integer
#  updated_by_id       :integer
#

require 'spec_helper'

describe EuDecision do
  before do
    @taxon_concept = create(:taxon_concept)
  end

  describe :create do
    context "downloads cache should be populated" do
      before(:each) do
        DownloadsCache.clear_eu_decisions
        create(:eu_decision, :start_date => Time.utc(2013), :type => 'EuOpinion')
        EuDecision.export('set' => 'current', 'decision_types' => {})
      end
      subject { Dir["#{DownloadsCache.eu_decisions_path}/*"] }
      specify { subject.should_not be_empty }
    end
  end

  describe :destroy do
    context "downloads cache should be cleared" do
      before(:each) do
        DownloadsCache.clear_eu_decisions
        d = create(:eu_decision, :start_date => Time.utc(2013))
        EuDecision.export('set' => 'current', 'decision_types' => {})
        d.destroy
        EuDecision.export('set' => 'current', 'decision_types' => {})
      end
      subject { Dir["#{DownloadsCache.eu_decisions_path}/*"] }
      specify { subject.should be_empty }
    end
  end

  #describe :start_date do
  #  context 'change type with start_date' do
  #    let(:eu_decision) { create(:eu_decision, :start_date => Time.utc(2013)) }
  #    specify { eu_decision.year.should == '2013' }
  #  end
  #end

  #context "validations" do
  #  describe :create do
  #    context "when restriction missing" do
  #      let(:eu_decision){
  #        build(
  #          :eu_decision,
  #          :restriction => nil,
  #          :taxon_concept => @taxon_concept
  #        )
  #      }

  #      specify { eu_decision.should be_invalid }
  #      specify { eu_decision.should have(2).error_on(:restriction) }
  #    end

  #    context "when start_date missing" do
  #      let(:eu_decision){
  #        build(
  #          :eu_decision,
  #          :start_date => nil,
  #          :taxon_concept => @taxon_concept
  #        )
  #      }

  #      specify { eu_decision.should be_invalid }
  #      specify { eu_decision.should have(1).error_on(:start_date) }
  #    end

  #    context "when start_date missing" do
  #      let(:eu_decision){
  #        build(
  #          :eu_decision,
  #          :taxon_concept => nil
  #        )
  #      }

  #      specify { eu_decision.should be_invalid }
  #      specify { eu_decision.should have(1).error_on(:taxon_concept) }
  #    end

  #    context "when valid" do
  #      let(:eu_decision){
  #        build(
  #          :eu_decision,
  #          :taxon_concept => @taxon_concept
  #        )
  #      }

  #      specify { eu_decision.should be_valid }
  #    end
  #  end
  #end
end
