require 'spec_helper'

describe EuSuspensionRegulationActivationWorker do
  let(:prev_eu_suspension_regulation){
    create(
      :eu_suspension_regulation,
      :name => 'REGULATION 1.0',
      :designation => eu,
      :is_current => true
    )
  }
  let!(:eu_suspension){
    create(:eu_suspension,
      :start_event_id => prev_eu_suspension_regulation.id,
      :end_date => nil,
      :is_current => true
    )
  }
  let!(:eu_suspension_regulation){
    create(:eu_suspension_regulation,
      :name => 'REGULATION 2.0',
      :eu_suspensions_event_id => prev_eu_suspension_regulation.id,
      :designation => eu,
      :is_current => false
    )
  }
  describe "Set new EU suspension regulation to true" do
    before do
      EventEuSuspensionCopyWorker.drain
      EuSuspensionRegulationActivationWorker.new.perform(eu_suspension_regulation.id, true)
    end

    specify { eu_suspension_regulation.eu_suspensions.reload.first.is_current.should be_true }

    describe "Set old EU suspension regulation to false" do
      before do
        EuSuspensionRegulationActivationWorker.new.perform(prev_eu_suspension_regulation.id, false)
      end

      specify { eu_suspension_regulation.eu_suspensions.reload.first.is_current.should be_true }
      specify { prev_eu_suspension_regulation.eu_suspensions.reload.first.is_current.should be_false }
    end
  end

end
