require 'spec_helper'

describe Purpose do
  describe :destroy do
    context "when no dependent objects attached" do
      let(:purpose){ create(:purpose) }
      specify { purpose.destroy.should be_true }
    end
    context "when dependent objects attached" do
      let(:purpose){ create(:purpose) }
      context "when CITES suspension" do
        let!(:suspension){ create(:suspension, :purposes => [purpose])}
        specify { purpose.destroy.should be_false }
      end
    end
  end
end
