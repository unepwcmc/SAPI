require 'spec_helper'

describe Term do
  describe :destroy do
    context "when no dependent objects attached" do
      let(:term){ create(:term) }
      specify { term.destroy.should be_true }
    end
    context "when dependent objects attached" do
      let(:term){ create(:term) }
      context "when EU opinion" do
        let!(:eu_opinion){ create(:eu_opinion, :term => term)}
        specify { term.destroy.should be_false }
      end
      context "when EU suspension" do
        let!(:eu_suspension){ create(:eu_suspension, :term => term)}
        specify { term.destroy.should be_false }
      end
      context "when CITES suspension" do
        let!(:suspension){ create(:suspension, :terms => [term])}
        specify { term.destroy.should be_false }
      end
      context "when CITES quota" do
        let!(:quota){ create(:quota, :terms => [term])}
        specify { term.destroy.should be_false }
      end
    end
  end
end
