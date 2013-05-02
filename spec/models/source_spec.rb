require 'spec_helper'

describe Source do
  describe :destroy do
    context "when no dependent objects attached" do
      let(:source){ create(:source) }
      specify { source.destroy.should be_true }
    end
    context "when dependent objects attached" do
      let(:source){ create(:source) }
      context "when EU opinion" do
        let!(:eu_opinion){ create(:eu_opinion, :source => source)}
        specify { source.destroy.should be_false }
      end
      context "when EU suspension" do
        let!(:eu_suspension){ create(:eu_suspension, :source => source)}
        specify { source.destroy.should be_false }
      end
      context "when CITES suspension" do
        let!(:suspension){ create(:suspension, :sources => [source])}
        specify { source.destroy.should be_false }
      end
      context "when CITES quota" do
        let!(:quota){ create(:quota, :sources => [source])}
        specify { source.destroy.should be_false }
      end
    end
  end
end
