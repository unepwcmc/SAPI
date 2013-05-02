require 'spec_helper'

describe Unit do
  describe :destroy do
    context "when no dependent objects attached" do
      let(:unit){ create(:unit) }
      specify { unit.destroy.should be_true }
    end
    context "when dependent objects attached" do
      let(:unit){ create(:unit) }
      let!(:quota){ create(:quota, :unit => unit)}
      specify { unit.destroy.should be_false }
    end
  end
end
