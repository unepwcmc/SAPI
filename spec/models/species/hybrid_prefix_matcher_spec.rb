require 'spec_helper'
describe Species::TaxonConceptPrefixMatcher do
  include_context "Falconiformes"
  describe :results do
    context "when searching for hybrid" do
      context "when trade visibility" do
        subject {
          Species::TaxonConceptPrefixMatcher.new({
            :taxon_concept_query => 'Falco hybrid',
            :ranks => [],
            :visibility => :trade
          })
        }
        specify { subject.results.should include(@hybrid_ac) }
      end
      context "when trade internal visibility" do
        subject {
          Species::TaxonConceptPrefixMatcher.new({
            :taxon_concept_query => 'Falco hybrid',
            :ranks => [],
            :visibility => :trade_internal
          })
        }
        specify { subject.results.should include(@hybrid_ac) }
      end
      context "when speciesplus visibility" do
        subject {
          Species::TaxonConceptPrefixMatcher.new({
            :taxon_concept_query => 'Falco hybrid',
            :ranks => []
          })
        }
        specify { subject.results.should be_empty }
      end
    end
  end
end
