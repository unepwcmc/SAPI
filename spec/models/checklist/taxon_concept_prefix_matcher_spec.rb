require 'spec_helper'

describe Checklist::TaxonConceptPrefixMatcher do
  include_context "Caiman latirostris"
  describe :taxon_concepts do
    context "when query in capital letters" do
      subject{
        Checklist::TaxonConceptPrefixMatcher.new({:scientific_name => 'CAI'})
      }
      specify{ subject.results.size.should == 2 }
    end
    context "when match on accepted name" do
      subject{
        Checklist::TaxonConceptPrefixMatcher.new({:scientific_name => 'cai'})
      }
      specify{ subject.results.size.should == 2 }
    end
    context "when match on synonym" do
      subject{
        Checklist::TaxonConceptPrefixMatcher.new({:scientific_name => 'alligator'})
      }
      specify{ subject.results.size.should == 2 }
    end
    context "when match on common name" do
      subject{
        Checklist::TaxonConceptPrefixMatcher.new({:scientific_name => 'broad'})
      }
      specify{ subject.results.size.should == 1 }
    end
  end
end