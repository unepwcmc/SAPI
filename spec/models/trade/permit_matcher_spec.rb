require 'spec_helper'
describe Trade::PermitMatcher do
  describe :results do
    context "when searching by permit number" do
      before(:each) do
        @permit = create(:permit, :number => '006AAA')
      end
      context "when regular query" do
        subject { Trade::PermitMatcher.new({ :permit_query => '006' }).results }
        specify { subject.should include(@permit) }
      end
      context "when wildcard query" do
        subject { Trade::PermitMatcher.new({ :permit_query => '%AA' }).results }
        specify { subject.should include(@permit) }
      end
      context "when malicious query" do
        subject { Trade::PermitMatcher.new({ :permit_query => '006\'' }).results }
        specify { subject.should be_empty }
      end
      context "when leading whitespace" do
        subject { Trade::PermitMatcher.new({ :permit_query => ' 006' }).results }
        specify { subject.should include(@permit) }
      end
      context "when trailing whitespace" do
        subject { Trade::PermitMatcher.new({ :permit_query => '006AAA ' }).results }
        specify { subject.should include(@permit) }
      end
    end
  end
end
