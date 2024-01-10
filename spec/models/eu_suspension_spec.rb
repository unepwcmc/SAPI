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

describe EuSuspension do

  describe :create do
    context "when taxon concept missing" do
      let(:eu_suspension) {
        build(
          :eu_suspension, taxon_concept: nil
        )
      }

      specify { eu_suspension.should be_invalid }
      specify { eu_suspension.should have(1).error_on(:taxon_concept) }
    end

    context "when geo_entity missing" do
      let(:eu_suspension) {
        build(
          :eu_suspension,
          geo_entity: nil
        )
      }

      specify { eu_suspension.should be_invalid }
      specify { eu_suspension.should have(1).error_on(:geo_entity) }
    end

    context "when valid" do
      let(:eu_suspension) { build(:eu_suspension) }

      specify { eu_suspension.should be_valid }
    end
  end

  describe :is_current do
    context "when start_event and end_event not set" do
      let(:eu_suspension) {
        create(:eu_suspension, start_event: nil, end_event: nil)
      }

      specify { eu_suspension.is_current.should be_falsey }
    end

    context "when start_event is set but date is in the future" do
      let(:start_event) {
        create(:event, effective_at: 2.days.from_now)
      }
      let(:eu_suspension) {
        create(:eu_suspension, start_event: start_event, end_event: nil)
      }

      specify { eu_suspension.is_current.should be_falsey }
    end

    context "when start_event is set but is not current" do
      let(:start_event) {
        create(:event, effective_at: 2.days.ago, is_current: false)
      }
      let(:eu_suspension) {
        create(:eu_suspension, start_event: start_event, end_event: nil)
      }

      specify { eu_suspension.is_current.should be_falsey }
    end

    context "when start_event is set but date is in past or present" do
      let(:start_event) {
        create(:event, effective_at: Date.today, is_current: true)
      }
      let(:start_event2) {
        create(:event, effective_at: 1.days.ago, is_current: true)
      }
      let(:eu_suspension) {
        create(:eu_suspension, start_event: start_event, end_event: nil)
      }

      let(:eu_suspension2) {
        create(:eu_suspension, start_event: start_event2, end_event: nil)
      }

      specify { eu_suspension.is_current.should be_truthy }
      specify { eu_suspension2.is_current.should be_truthy }
    end

    context "when end_event is set, but no start_event is set" do
      let(:end_event) {
        create(:event, effective_at: Date.today)
      }
      let(:eu_suspension) {
        create(:eu_suspension, start_event: nil, end_event: end_event)
      }

      specify { eu_suspension.is_current.should be_falsey }
    end

    context "when end_event is set, and start_event is set with date in future" do
      let(:end_event) {
        create(:event, effective_at: Date.today)
      }
      let(:start_event) {
        create(:event, effective_at: 1.day.from_now)
      }
      let(:eu_suspension) {
        create(:eu_suspension, start_event: start_event, end_event: end_event)
      }

      specify { eu_suspension.is_current.should be_falsey }
    end

    context "when  start_event is set, and end_event is set with date in the future" do
      let(:end_event) {
        create(:event, effective_at: 1.day.from_now)
      }
      let(:start_event) {
        create(:event, effective_at: 1.day.ago, is_current: true)
      }
      let(:eu_suspension) {
        create(:eu_suspension, start_event: start_event, end_event: end_event)
      }

      specify { eu_suspension.is_current.should be_truthy }
    end

    context "when  start_event is set, and end_event is set with date in the past" do
      let(:end_event) {
        create(:event, effective_at: 1.day.ago)
      }
      let(:start_event) {
        create(:event, effective_at: 2.day.ago)
      }
      let(:eu_suspension) {
        create(:eu_suspension, start_event: start_event, end_event: end_event)
      }

      specify { eu_suspension.is_current.should be_falsey }
    end
  end

  describe :start_date_formatted do
    context "when there's no start_event" do
      let(:eu_suspension) {
        create(:eu_suspension, start_event: nil)
      }
      specify { eu_suspension.start_date_formatted.should be_empty }
    end

    context "when there's start_event" do
      let(:eu_suspension) {
        create(:eu_suspension, start_event: start_event)
      }
      let(:start_event) {
        create(:event, effective_at: 2.day.ago)
      }
      specify { eu_suspension.start_date_formatted.should == 2.day.ago.strftime("%d/%m/%Y") }
    end
  end

  describe :end_date_formatted do
    context "when there's no end_event" do
      let(:eu_suspension) {
        create(:eu_suspension, end_event: nil)
      }
      specify { eu_suspension.end_date_formatted.should be_empty }
    end

    context "when there's end_event" do
      let(:eu_suspension) {
        create(:eu_suspension, end_event: end_event)
      }
      let(:end_event) {
        create(:event, effective_at: 2.day.ago)
      }
      specify { eu_suspension.end_date_formatted.should == 2.day.ago.strftime("%d/%m/%Y") }
    end
  end
end
