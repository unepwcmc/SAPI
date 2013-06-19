# == Schema Information
#
# Table name: eu_decisions
#
#  id               :integer          not null, primary key
#  type             :string(255)
#  law_id           :integer
#  taxon_concept_id :integer
#  geo_entity_id    :integer
#  start_date       :datetime
#  end_date         :datetime
#  restriction      :string(255)
#  restriction_text :text
#  term_id          :integer
#  source_id        :integer
#  conditions       :boolean
#  comments         :text
#  is_current       :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  conditions_apply :boolean
#

require 'spec_helper'

describe EuDecision do
  before do
    @taxon_concept = create(:taxon_concept)
  end

  describe :start_date do
    context 'change type with start_date' do
      let(:eu_decision) { create(:eu_decision, :start_date => Time.utc(2013)) }
      specify { eu_decision.year.should == '2013' }
    end
  end

  context "validations" do
    describe :create do
      context "when restriction missing" do
        let(:eu_decision){
          build(
            :eu_decision,
            :restriction => nil,
            :taxon_concept => @taxon_concept
          )
        }

        specify { eu_decision.should be_invalid }
        specify { eu_decision.should have(2).error_on(:restriction) }
      end

      context "when start_date missing" do
        let(:eu_decision){
          build(
            :eu_decision,
            :start_date => nil,
            :taxon_concept => @taxon_concept
          )
        }

        specify { eu_decision.should be_invalid }
        specify { eu_decision.should have(1).error_on(:start_date) }
      end

      context "when start_date missing" do
        let(:eu_decision){
          build(
            :eu_decision,
            :taxon_concept => nil
          )
        }

        specify { eu_decision.should be_invalid }
        specify { eu_decision.should have(1).error_on(:taxon_concept) }
      end

      context "when valid" do
        let(:eu_decision){
          build(
            :eu_decision,
            :taxon_concept => @taxon_concept
          )
        }

        specify { eu_decision.should be_valid }
      end
    end
  end
end
