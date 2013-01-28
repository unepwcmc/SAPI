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
end
