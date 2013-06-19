# == Schema Information
#
# Table name: trade_restrictions
#
#  id                          :integer          not null, primary key
#  is_current                  :boolean
#  start_date                  :datetime
#  end_date                    :datetime
#  geo_entity_id               :integer
#  quota                       :float
#  publication_date            :datetime
#  notes                       :text
#  type                        :string(255)
#  unit_id                     :integer
#  taxon_concept_id            :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  public_display              :boolean          default(TRUE)
#  url                         :text
#  start_notification_id       :integer
#  end_notification_id         :integer
#  excluded_taxon_concepts_ids :string
#

require 'spec_helper'

describe CitesSuspension do
  before do
    @taxon_concept = create(:taxon_concept)
  end

  context "validations" do
    describe :create do
      context "when start notification missing" do
        let(:cites_suspension){
          build(
            :cites_suspension,
            :start_notification => nil,
            :taxon_concept => @taxon_concept
          )
        }

        specify { cites_suspension.should be_invalid }
        specify { cites_suspension.should have(1).error_on(:start_notification_id) }
      end

      context "when start date greater than end date" do
        let(:cites_suspension){
          build(
            :cites_suspension,
            :start_notification => create_cites_suspension_notification(:effective_at => 1.week.from_now),
            :end_notification => create_cites_suspension_notification(:effective_at => 1.week.ago),
            :taxon_concept => @taxon_concept
          )
        }

        specify { cites_suspension.should be_invalid }
        specify { cites_suspension.should have(1).error_on(:start_date) }
      end

      context "when valid" do
        let(:cites_suspension){
          build(
            :cites_suspension,
            :taxon_concept => @taxon_concept,
            :start_notification => create_cites_suspension_notification
          )
        }

        specify { cites_suspension.should be_valid }
      end
    end
  end
end
