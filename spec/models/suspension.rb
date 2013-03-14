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

describe Suspension do
  before do
    @taxon_concept = create(:taxon_concept)
  end

  context "validations" do
    describe :create do
      context "when publication date missing" do
        let(:suspension){
          build(
            :suspension,
            :publication_date => nil,
            :taxon_concept => @taxon_concept
          )
        }

        specify { suspension.should be_invalid }
        specify { suspension.should have(1).error_on(:publication_date) }
      end

      context "when start date greater than end date" do
        let(:suspension){
          build(
            :suspension,
            :start_date => 1.week.from_now,
            :end_date => 1.week.ago,
            :taxon_concept => @taxon_concept
          )
        }

        specify { suspension.should be_invalid }
        specify { suspension.should have(1).error_on(:start_date) }
      end

      context "when valid" do
        let(:suspension){
          build(
            :suspension,
            :taxon_concept => @taxon_concept
          )
        }

        specify { suspension.should be_valid }
      end
    end
  end
end
