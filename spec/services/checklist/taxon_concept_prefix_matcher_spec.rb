require 'spec_helper'

describe Species::TaxonConceptPrefixMatcher do
  include_context 'Boa constrictor'
  describe :results do
    context 'when query in capital letters' do
      subject do
        Species::TaxonConceptPrefixMatcher.new(
          {
            taxon_concept_query: 'BOA',
            ranks: []
          }
        )
      end
      specify { expect(subject.results.size).to eq(3) }
    end
    context 'when match on accepted name' do
      subject do
        Species::TaxonConceptPrefixMatcher.new(
          {
            taxon_concept_query: 'boa',
            ranks: []
          }
        )
      end
      specify { expect(subject.results.size).to eq(3) }
    end
    context 'when match on synonym' do
      subject do
        Species::TaxonConceptPrefixMatcher.new(
          {
            taxon_concept_query: 'constrictor',
            ranks: []
          }
        )
      end
      specify { expect(subject.results.size).to eq(2) }
    end
    context 'when match on common name' do
      subject do
        Species::TaxonConceptPrefixMatcher.new(
          {
            taxon_concept_query: 'red',
            ranks: []
          }
        )
      end
      specify { expect(subject.results.size).to eq(1) }
    end
  end
end
