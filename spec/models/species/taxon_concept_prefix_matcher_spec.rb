require 'spec_helper'
describe Species::TaxonConceptPrefixMatcher do
  include_context "Canis lupus"
  describe :results do
    context "when searching by scientific name" do
      context "when regular query" do
        subject { Species::TaxonConceptPrefixMatcher.new({:taxon_concept_query => 'canis'}).results }
        specify { subject.should include(@species)}
      end
      context "when malicious query" do
        subject { Species::TaxonConceptPrefixMatcher.new({:taxon_concept_query => 'canis\''}).results }
        specify { subject.should be_empty}
      end
      context "when leading whitespace" do
        subject { Species::TaxonConceptPrefixMatcher.new({:taxon_concept_query => ' canis'}).results }
        specify { subject.should include(@species)}
      end      
      context "when trailing whitespace" do
        subject { Species::TaxonConceptPrefixMatcher.new({:taxon_concept_query => 'canis '}).results }
        specify { subject.should include(@species)}
      end 
    end
  end
end