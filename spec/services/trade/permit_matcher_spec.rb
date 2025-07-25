require 'spec_helper'
describe Trade::PermitMatcher do
  describe :results do
    context 'when searching by permit number' do
      before(:each) do
        @permit = create(:permit, number: '006AAA')
        @permit_percent = create(:permit, number: '100%')
      end
      context 'when regular query' do
        subject { Trade::PermitMatcher.new({ permit_query: '006' }).results }
        specify { expect(subject).to include(@permit) }
      end
      context 'when wildcard in query, do not inject as wildcard' do
        subject { Trade::PermitMatcher.new({ permit_query: '%AA' }).results }
        specify { expect(subject).to be_empty }
      end
      context 'when wildcard in query, treat as literal instead' do
        subject { Trade::PermitMatcher.new({ permit_query: '100%' }).results }
        specify { expect(subject).to include(@permit_percent) }
      end
      context 'when case mismatch in query' do
        subject { Trade::PermitMatcher.new({ permit_query: '006aa' }).results }
        specify { expect(subject).to include(@permit) }
      end
      context 'when malicious query' do
        subject { Trade::PermitMatcher.new({ permit_query: '006\'' }).results }
        specify { expect(subject).to be_empty }
      end
      context 'when leading whitespace' do
        subject { Trade::PermitMatcher.new({ permit_query: ' 006' }).results }
        specify { expect(subject).to include(@permit) }
      end
      context 'when trailing whitespace' do
        subject { Trade::PermitMatcher.new({ permit_query: '006AAA ' }).results }
        specify { expect(subject).to include(@permit) }
      end
    end
  end
end
