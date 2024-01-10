require 'spec_helper'

describe TaxonConcept do
  context "Uroplatus" do
    include_context "Uroplatus"

    context "REFERENCES" do
      describe :cites_accepted do
        context "for genus Uroplatus" do
          specify { @genus.cites_accepted.should == false }
        end
        context "for species Uroplatus alluaudi" do
          specify { @species1.cites_accepted.should == false }
        end
        context "for species Uroplatus giganteus" do
          specify { @species2.cites_accepted.should be_truthy }
        end
      end
      describe :standard_taxon_concept_references do
        context "for family Gekkonidae" do
          specify { @family.taxon_concept.standard_taxon_concept_references.should be_empty }
        end
        context "for genus Uroplatus" do
          specify { @genus.taxon_concept.standard_taxon_concept_references.map(&:reference_id).should be_empty }
        end
        context "for species Uroplatus alluaudi" do
          specify { @species1.taxon_concept.standard_taxon_concept_references.map(&:reference_id).should be_empty }
        end
        context "for species Uroplatus giganteus" do
          specify { @species2.taxon_concept.standard_taxon_concept_references.map(&:reference_id).should include @ref.id }
        end
      end
    end
    context "LISTING" do
      describe :cites_listing do
        context "for genus Uroplatus" do
          specify { @genus.cites_listing.should == 'II' }
        end
        context "for species Uroplatus giganteus" do
          specify { @species2.cites_listing.should == 'II' }
        end
      end

      describe :eu_listing do
        context "for genus Uroplatus" do
          specify { @genus.eu_listing.should == 'B' }
        end
        context "for species Uroplatus giganteus" do
          specify { @species2.eu_listing.should == 'B' }
        end
      end

      describe :cites_listed do
        context "for family Gekkonidae" do
          specify { @family.cites_listed.should == false }
        end
        context "for genus Uroplatus" do
          specify { @genus.cites_listed.should be_truthy }
        end
        context "for species Uroplatus giganteus" do
          specify { @species2.cites_listed.should == false }
        end
      end

      describe :eu_listed do
        context "for family Gekkonidae" do
          specify { @family.eu_listed.should == false }
        end
        context "for genus Uroplatus" do
          specify { @genus.eu_listed.should be_truthy }
        end
        context "for species Uroplatus giganteus" do
          specify { @species2.eu_listed.should == false }
        end
      end

    end
  end
end
