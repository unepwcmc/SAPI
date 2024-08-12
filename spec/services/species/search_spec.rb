require 'spec_helper'
describe Species::Search do
  include_context 'Canis lupus'
  describe :results do
    context 'when searching by scientific name' do
      context 'when regular query' do
        subject { Species::Search.new({ taxon_concept_query: 'canis' }).results }
        specify { expect(subject).to include(@species) }
      end
      context 'when malicious query' do
        subject { Species::Search.new({ taxon_concept_query: 'canis\'' }).results }
        specify { expect(subject).to be_empty }
      end
      context 'when leading whitespace' do
        subject { Species::Search.new({ taxon_concept_query: ' canis' }).results }
        specify { expect(subject).to include(@species) }
      end
      context 'when trailing whitespace' do
        subject { Species::Search.new({ taxon_concept_query: 'canis ' }).results }
        specify { expect(subject).to include(@species) }
      end
    end
  end
end
