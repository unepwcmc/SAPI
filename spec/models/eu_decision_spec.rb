require 'spec_helper'

describe EuDecision do
  describe :start_date do
    context 'change type with start_date' do
      let(:eu_decision) { create(:eu_decision, :start_date => Time.utc(2013)) }
      specify { eu_decision.year.should == '2013' }
    end
  end
end
