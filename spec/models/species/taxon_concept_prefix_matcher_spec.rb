require 'spec_helper'
describe Species::TaxonConceptPrefixMatcher do
  include_context "Boa constrictor"
  describe :results do
    context "when searching by scientific name" do
      context "when regular query" do
        subject {
          Species::TaxonConceptPrefixMatcher.new({
            :taxon_concept_query => 'boa',
            :ranks => []
          })
        }
        specify { subject.results.should include(@species)}
      end
      context "when malicious query" do
        subject {
          Species::TaxonConceptPrefixMatcher.new({
            :taxon_concept_query => 'boa\'',
            :ranks => []
          })
        }
        specify { subject.results.should be_empty}
      end
      context "when leading whitespace" do
        subject {
          Species::TaxonConceptPrefixMatcher.new({
            :taxon_concept_query => ' boa',
            :ranks => []
          })
        }
        specify { subject.results.should include(@species)}
      end
      context "when trailing whitespace" do
        subject {
          Species::TaxonConceptPrefixMatcher.new({
            :taxon_concept_query => 'boa ',
            :ranks => []
          })
        }
        specify { subject.results.should include(@species)}
      end
      context "when implicitly listed subspecies" do
        subject {
          Species::TaxonConceptPrefixMatcher.new({
            :taxon_concept_query => 'boa constrictor',
            :ranks => []
          })
        }
        specify { subject.results.should_not include(@subspecies2)}
      end
      context "when explicitly listed subspecies" do
        subject {
          Species::TaxonConceptPrefixMatcher.new({
            :taxon_concept_query => 'boa constrictor',
            :ranks => []
          })
        }
        specify { subject.results.should include(@subspecies1)}
      end
      context "when implicitly listed higher taxon (without an explicitly listed ancestor)" do
        subject {
          Species::TaxonConceptPrefixMatcher.new({
            :taxon_concept_query => 'serpentes',
            :ranks => []
          })
        }
        specify { subject.results.should include(@order)}
      end
      context "when explicitly listed higher taxon" do
        subject {
          Species::TaxonConceptPrefixMatcher.new({
            :taxon_concept_query => 'boidae',
            :ranks => []
          })
        }
        specify { subject.results.should include(@family)}
      end
      #check ranks filtering
      context "when explicitly listed higher taxon but ranks expected FAMILY" do
        subject {
          Species::TaxonConceptPrefixMatcher.new({
            :taxon_concept_query => 'boidae',
            :ranks => ["FAMILY"]
          })
        }
        specify { subject.results.should include(@family)}
      end
      context "when explicitly listed higher taxon but ranks expected SPECIES" do
        subject {
          Species::TaxonConceptPrefixMatcher.new({
            :taxon_concept_query => 'boidae',
            :ranks => ["SPECIES"]
          })
        }
        specify { subject.results.should be_empty }
      end
      context "when searching for name that matches Species and Subspecies but  ranks expected SUBSPECIES" do
        subject {
          Species::TaxonConceptPrefixMatcher.new({
            :taxon_concept_query => 'boa constrictor',
            :ranks => ["SUBSPECIES"]
          })
        }
        specify {
          subject.results.should_not include(@species)
          subject.results.should include(@subspecies1)
        }
      end
    end
  end
end
