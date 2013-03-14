# == Schema Information
#
# Table name: trade_restrictions
#
#  id               :integer          not null, primary key
#  is_current       :boolean
#  start_date       :datetime
#  end_date         :datetime
#  geo_entity_id    :integer
#  quota            :integer
#  publication_date :datetime
#  notes            :text
#  suspension_basis :string(255)
#  type             :string(255)
#  unit_id          :integer
#  term_id          :integer
#  source_id        :integer
#  purpose_id       :integer
#  taxon_concept_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'spec_helper'

describe Quota do
  before do
    @taxon_concept = create(:taxon_concept)
  end

  context "validations" do
    describe :create do
      before(:all) do
        @unit = create(:unit)
      end

      context "when valid" do
        let(:quota){
          build(
            :quota,
            :unit => @unit,
            :taxon_concept => @taxon_concept
          )
        }

        specify {quota.should be_valid}
      end

      context "when quota missing" do
        let(:quota1){
          build(
            :quota,
            :quota => nil,
            :unit => @unit,
            :taxon_concept => @taxon_concept
          )
        }

        specify { quota1.should be_invalid }
        specify { quota1.should have(2).error_on(:quota) }
      end

      context "when publication date missing" do
        let(:quota){
          build(
            :quota,
            :publication_date => nil,
            :unit => @unit,
            :taxon_concept => @taxon_concept
          )
        }

        specify { quota.should be_invalid }
        specify { quota.should have(1).error_on(:publication_date) }
      end

      context "when start date greater than end date" do
        let(:quota){
          build(
            :quota,
            :start_date => 1.week.from_now,
            :end_date => 1.week.ago,
            :unit => @unit,
            :taxon_concept => @taxon_concept
          )
        }

        specify { quota.should be_invalid }
        specify { quota.should have(1).error_on(:start_date) }
      end

      context "doesn't save a quota without a unit" do
        let(:quota){
          build(
            :quota,
            :unit => nil,
            :taxon_concept => @taxon_concept
          )
        }

        specify {quota.should_not be_valid}
        specify { quota.should have(1).error_on(:unit) }
      end
    end
  end
end
