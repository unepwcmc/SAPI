# == Schema Information
#
# Table name: eu_decisions
#
#  id                   :integer          not null, primary key
#  is_current           :boolean          default(TRUE)
#  notes                :text
#  internal_notes       :text
#  taxon_concept_id     :integer
#  geo_entity_id        :integer          not null
#  start_date           :datetime
#  start_event_id       :integer
#  end_date             :datetime
#  end_event_id         :integer
#  type                 :string(255)
#  conditions_apply     :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  eu_decision_type_id  :integer
#  term_id              :integer
#  source_id            :integer
#  created_by_id        :integer
#  updated_by_id        :integer
#  nomenclature_note_en :text
#  nomenclature_note_es :text
#  nomenclature_note_fr :text
#

require 'spec_helper'

describe EuOpinion do

  describe :create do
    context "when taxon concept missing" do
      let(:eu_opinion) {
        build(
          :eu_opinion, taxon_concept: nil
        )
      }

      specify { eu_opinion.should be_invalid }
      specify { eu_opinion.should have(1).error_on(:taxon_concept) }
    end

    context "when geo_entity missing" do
      let(:eu_opinion) {
        build(
          :eu_opinion, geo_entity: nil
        )
      }

      specify { eu_opinion.should be_invalid }
      specify { eu_opinion.should have(1).error_on(:geo_entity) }
    end

    context "when start_date missing" do
      let(:eu_opinion) {
        build(:eu_opinion, start_date: nil)
      }

      specify { eu_opinion.should be_invalid }
      specify { eu_opinion.should have(1).error_on(:start_date) }
    end

    context "when valid" do
      before do
        @eu_regulation = create(:ec_srg)
      end
      let(:eu_opinion) { build(:eu_opinion, start_event: @eu_regulation) }

      specify { eu_opinion.should be_valid }
    end
  end

end
