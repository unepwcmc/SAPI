#Encoding: utf-8
require 'spec_helper'

describe TaxonConcept do
  context "Varanidae" do
    include_context "Varanidae"

    context "REFERENCES" do
      describe :cites_accepted do
        context "for species Varanus bengalensis" do
          specify { @species1.cites_accepted.should be_true }
        end
      end
      describe :standard_references do
        context "for order Sauria" do
          specify { @order.taxon_concept.standard_references.should be_empty }
        end
        context "for family Varanidae" do
          specify { @family.taxon_concept.standard_references.map(&:id).should include @ref1.id }
        end
        context "for species Varanus bengalensis" do
          specify { @species1.taxon_concept.standard_references.map(&:id).should include @ref1.id }
        end
        context "for species Varanus bushi" do
          specify { @species2.taxon_concept.standard_references.map(&:id).should include @ref1.id }
          specify { @species2.taxon_concept.standard_references.map(&:id).should include @ref2.id }
        end
      end
    end
    context "LISTING" do
      describe :current_listing do
        context "for genus Varanus" do
          specify { @genus.current_listing.should == 'I/II' }
        end
        context "for species Varanus bengalensis" do
          specify { @species1.current_listing.should == 'I' }
        end
      end

      describe :cites_listed do
        context "for family Varanidae" do
          specify { @family.cites_listed.should == false }
        end
        context "for genus Varanus" do
          specify { @genus.cites_listed.should be_true }
        end
        context "for species Varanus bengalensis" do
          specify { @species1.cites_listed.should be_true }
        end
      end

      describe :eu_listed do
        context "for family Varanidae" do
          specify { @family.eu_listed.should == false }
        end
        context "for genus Varanus" do
          specify { @genus.eu_listed.should be_true }
        end
        context "for species Varanus bengalensis" do
          specify { @species1.eu_listed.should be_true }
        end
      end

    end
  end
end