require 'spec_helper'

describe Taxonomy do
  describe :create do
    context "when valid" do
      let(:taxonomy){build(:taxonomy, :name => 'WILDLIFE')}
      specify {taxonomy.should be_valid}
    end
    context "when invalid" do
      let(:taxonomy){build(:taxonomy, :name => nil)}
      specify {taxonomy.should be_invalid}
    end
  end
  describe :destroy do
    context "when no child objects attached" do
      let(:taxonomy){ create(:taxonomy, :name => 'WILDLIFE') }
      specify {taxonomy.destroy.should be_true}
    end
    context "when child objects attached" do
      let(:taxonomy){ create(:taxonomy, :name => 'WILDLIFE') }
      let!(:designation){ create(:designation, :taxonomy => taxonomy)}
      specify {taxonomy.destroy.should be_false}
    end
    context "when protected taxonomy name" do
      let(:taxonomy){ create(:taxonomy, :name => Taxonomy::WILDLIFE_TRADE) }
      specify {taxonomy.destroy.should be_false}
    end
  end
end
