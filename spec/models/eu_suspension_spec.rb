require 'spec_helper'

describe EuSuspension do

  describe :is_current do
    context "when start_event and end_event not set" do
      let(:eu_suspension) {
        create(:eu_suspension,
               :start_event => nil,
               :end_event => nil)
      }

      specify { eu_suspension.is_current.should be_false }
    end

    context "when start_event is set but date is in the future" do
      let(:start_event) {
        create(:event,
               :effective_at => 2.days.from_now)
      }
      let(:eu_suspension) {
        create(:eu_suspension,
               :start_event => start_event,
               :end_event => nil)
      }

      specify { eu_suspension.is_current.should be_false }
    end

    context "when start_event is set but date is in past or present" do
      let(:start_event) {
        create(:event,
               :effective_at => Date.today)
      }
      let(:start_event2) {
        create(:event,
               :effective_at => 1.days.ago)
      }
      let(:eu_suspension) {
        create(:eu_suspension,
               :start_event => start_event,
               :end_event => nil)
      }

      let(:eu_suspension2) {
        create(:eu_suspension,
               :start_event => start_event2,
               :end_event => nil)
      }

      specify { eu_suspension.is_current.should be_true }
      specify { eu_suspension2.is_current.should be_true }
    end

    context "when end_event is set, but no start_event is set" do
      let(:end_event) {
        create(:event,
               :effective_at => Date.today)
      }
      let(:eu_suspension) {
        create(:eu_suspension,
               :start_event => nil,
               :end_event => end_event)
      }

      specify { eu_suspension.is_current.should be_false }
    end

    context "when end_event is set, and start_event is set with date in future" do
      let(:end_event) {
        create(:event,
               :effective_at => Date.today)
      }
      let(:start_event) {
        create(:event,
               :effective_at => 1.day.from_now)
      }
      let(:eu_suspension) {
        create(:eu_suspension,
               :start_event => start_event,
               :end_event => end_event)
      }

      specify { eu_suspension.is_current.should be_false }
    end

    context "when  start_event is set, and end_event is set with date in the future" do
      let(:end_event) {
        create(:event,
               :effective_at => 1.day.from_now)
      }
      let(:start_event) {
        create(:event,
               :effective_at => 1.day.ago)
      }
      let(:eu_suspension) {
        create(:eu_suspension,
               :start_event => start_event,
               :end_event => end_event)
      }

      specify { eu_suspension.is_current.should be_true }
    end

    context "when  start_event is set, and end_event is set with date in the past" do
      let(:end_event) {
        create(:event,
               :effective_at => 1.day.ago)
      }
      let(:start_event) {
        create(:event,
               :effective_at => 2.day.ago)
      }
      let(:eu_suspension) {
        create(:eu_suspension,
               :start_event => start_event,
               :end_event => end_event)
      }

      specify { eu_suspension.is_current.should be_false }
    end
  end

  describe :start_date_formatted do
    context "when there's no start_event" do
      let(:eu_suspension) {
        create(:eu_suspension,
               :start_event => nil)
      }
      specify { eu_suspension.start_date_formatted.should be_empty }
    end

    context "when there's start_event" do
      let(:eu_suspension) {
        create(:eu_suspension,
               :start_event => start_event)
      }
      let(:start_event) {
        create(:event,
               :effective_at => 2.day.ago)
      }
      specify { eu_suspension.start_date_formatted.should == 2.day.ago.strftime("%d/%m/%Y") }
    end
  end

  describe :end_date_formatted do
    context "when there's no end_event" do
      let(:eu_suspension) {
        create(:eu_suspension,
               :end_event => nil)
      }
      specify { eu_suspension.end_date_formatted.should be_empty }
    end

    context "when there's end_event" do
      let(:eu_suspension) {
        create(:eu_suspension,
               :end_event => end_event)
      }
      let(:end_event) {
        create(:event,
               :effective_at => 2.day.ago)
      }
      specify { eu_suspension.end_date_formatted.should == 2.day.ago.strftime("%d/%m/%Y") }
    end
  end
end
