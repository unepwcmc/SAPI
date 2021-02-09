require 'spec_helper'

describe TaxonConcept do
  context "Varanidae" do
    include_context "Varanidae"

    context "REFERENCES" do
      describe :cites_accepted do
        context "for species Varanus bengalensis" do
          specify { @species1.cites_accepted.should be_truthy }
        end
      end
      describe :standard_taxon_concept_references do
        context "for order Sauria" do
          specify { @order.taxon_concept.standard_taxon_concept_references.should be_empty }
        end
        context "for family Varanidae" do
          specify { @family.taxon_concept.standard_taxon_concept_references.map(&:reference_id).should include @ref1.id }
        end
        context "for species Varanus bengalensis" do
          specify { @species1.taxon_concept.standard_taxon_concept_references.map(&:reference_id).should include @ref1.id }
        end
        context "for species Varanus bushi" do
          specify { @species2.taxon_concept.standard_taxon_concept_references.map(&:reference_id).should include @ref1.id }
          specify { @species2.taxon_concept.standard_taxon_concept_references.map(&:reference_id).should include @ref2.id }
        end
      end
    end
    context "LISTING" do
      describe :cites_listing do
        context "for genus Varanus" do
          specify { @genus.cites_listing.should == 'I/II' }
        end
        context "for species Varanus bengalensis" do
          specify { @species1.cites_listing.should == 'I' }
        end
      end

      describe :eu_listing do
        context "for genus Varanus" do
          specify { @genus.eu_listing.should == 'A/B' }
        end
        context "for species Varanus bengalensis" do
          specify { @species1.eu_listing.should == 'A' }
        end
      end

      describe :cites_listed do
        context "for family Varanidae" do
          specify { @family.cites_listed.should == false }
        end
        context "for genus Varanus" do
          specify { @genus.cites_listed.should be_truthy }
        end
        context "for species Varanus bengalensis" do
          specify { @species1.cites_listed.should be_truthy }
        end
      end

      describe :eu_listed do
        context "for family Varanidae" do
          specify { @family.eu_listed.should == false }
        end
        context "for genus Varanus" do
          specify { @genus.eu_listed.should be_truthy }
        end
        context "for species Varanus bengalensis" do
          specify { @species1.eu_listed.should be_truthy }
        end
      end

    end
  end
end
