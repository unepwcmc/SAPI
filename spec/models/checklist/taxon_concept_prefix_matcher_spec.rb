require 'spec_helper'

describe Species::TaxonConceptPrefixMatcher do
  include_context "Caiman latirostris"
  describe :taxon_concepts do
    context "when query in capital letters" do
      subject{
        Species::TaxonConceptPrefixMatcher.new({:taxon_concept_query => 'CAI', :from_checklist => true})
      }
      specify{ subject.results.size.should == 2 }
    end
    context "when match on accepted name" do
      subject{
        Species::TaxonConceptPrefixMatcher.new({:taxon_concept_query => 'cai', :from_checklist => true})
      }
      specify{ subject.results.size.should == 2 }
    end
    context "when match on synonym" do
      subject{
        Species::TaxonConceptPrefixMatcher.new({:taxon_concept_query => 'alligator', :from_checklist => true})
      }
      specify{ subject.results.size.should == 2 }
    end
    context "when match on common name" do
      subject{
        Species::TaxonConceptPrefixMatcher.new({:taxon_concept_query => 'broad', :from_checklist => true})
      }
      specify{ subject.results.size.should == 1 }
    end
  end
end