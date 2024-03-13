require 'spec_helper'

describe Species::TaxonConceptPrefixMatcher do
  include_context "Boa constrictor"
  describe :results do
    context "when query in capital letters" do
      subject {
        Species::TaxonConceptPrefixMatcher.new({
          :taxon_concept_query => 'BOA',
          :ranks => []
        })
      }
      specify { expect(subject.results.size).to eq(3) }
    end
    context "when match on accepted name" do
      subject {
        Species::TaxonConceptPrefixMatcher.new({
          :taxon_concept_query => 'boa',
          :ranks => []
        })
      }
      specify { expect(subject.results.size).to eq(3) }
    end
    context "when match on synonym" do
      subject {
        Species::TaxonConceptPrefixMatcher.new({
          :taxon_concept_query => 'constrictor',
          :ranks => []
        })
      }
      specify { expect(subject.results.size).to eq(2) }
    end
    context "when match on common name" do
      subject {
        Species::TaxonConceptPrefixMatcher.new({
          :taxon_concept_query => 'red',
          :ranks => []
        })
      }
      specify { expect(subject.results.size).to eq(1) }
    end
  end
end
