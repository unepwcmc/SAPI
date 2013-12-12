require 'spec_helper'

describe Species::TaxonConceptPrefixMatcher do
  include_context "Boa constrictor"
  describe :results do
    context "when query in capital letters" do
      subject{
        Species::TaxonConceptPrefixMatcher.new({
          :taxon_concept_query => 'BOA',
          :from_checklist => true,
          :ranks => []
        })
      }
      specify{ subject.results.size.should == 3 }
    end
    context "when match on accepted name" do
      subject{
        Species::TaxonConceptPrefixMatcher.new({
          :taxon_concept_query => 'boa',
          :from_checklist => true,
          :ranks => []
        })
      }
      specify{ subject.results.size.should == 3 }
    end
    context "when match on synonym" do
      subject{
        Species::TaxonConceptPrefixMatcher.new({
          :taxon_concept_query => 'constrictor',
          :from_checklist => true,
          :ranks => []
        })
      }
      specify{ subject.results.size.should == 1 }
    end
    context "when match on common name" do
      subject{
        Species::TaxonConceptPrefixMatcher.new({
          :taxon_concept_query => 'red',
          :from_checklist => true,
          :ranks => []
        })
      }
      specify{ subject.results.size.should == 1 }
    end
    context "when implicitly listed subspecies" do
      subject {
        Species::TaxonConceptPrefixMatcher.new({
          :taxon_concept_query => 'boa constrictor',
          :from_checklist => true,
          :ranks => []
        })
      }
      specify { subject.results.should_not include(@subspecies2)}
    end
    context "when explicitly listed subspecies" do
      subject {
        Species::TaxonConceptPrefixMatcher.new({
          :taxon_concept_query => 'boa constrictor',
          :from_checklist => true,
          :ranks => []
        })
      }
      specify { subject.results.should include(@subspecies1)}
    end
    context "when implicitly listed higher taxon (without an explicitly listed ancestor)" do
      subject {
        Species::TaxonConceptPrefixMatcher.new({
          :taxon_concept_query => 'serpentes',
          :from_checklist => true,
          :ranks => []
        })
      }
      specify { subject.results.should_not include(@order)}
    end
    context "when explicitly listed higher taxon" do
      subject {
        Species::TaxonConceptPrefixMatcher.new({
          :taxon_concept_query => 'boidae',
          :from_checklist => true,
          :ranks => []
        })
      }
      specify { subject.results.should include(@family)}
    end
  end
end