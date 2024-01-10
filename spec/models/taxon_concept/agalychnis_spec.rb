require 'spec_helper'

describe TaxonConcept do
  context "Agalychnis" do
    include_context "Agalychnis"

    context "REFERENCES" do
      describe :cites_accepted do
        context "for class Amphibia" do
          specify { @klass.cites_accepted.should be_truthy }
        end
        context "for family Hylidae" do
          specify { @family.cites_accepted.should be_truthy }
        end
        context "for genus Agalychnis" do
          specify { @genus.cites_accepted.should == false }
        end
      end
      describe :standard_taxon_concept_references do
        context "for class Amphibia" do
          specify { @klass.taxon_concept.standard_taxon_concept_references.map(&:reference_id).should include @ref.id }
        end
        context "for family Hylidae" do
          specify { @family.taxon_concept.standard_taxon_concept_references.map(&:reference_id).should include @ref.id }
        end
        context "for genus Agalychnis" do
          specify { @genus.taxon_concept.standard_taxon_concept_references.should be_empty }
        end
      end
    end
    context "LISTING" do
      describe :cites_listing do
        context "for genus Agalychnis" do
          specify { @genus.cites_listing.should == 'II' }
        end
      end

      describe :eu_listing do
        context "for genus Agalychnis" do
          specify { @genus.eu_listing.should == 'B' }
        end
      end

      describe :cites_listed do
        context "for family Hylidae" do
          specify { @family.cites_listed.should == false }
        end
        context "for genus Agalychnis" do
          specify { @genus.cites_listed.should be_truthy }
        end
      end

      describe :eu_listed do
        context "for family Hylidae" do
          specify { @family.eu_listed.should == false }
        end
        context "for genus Agalychnis" do
          specify { @genus.eu_listed.should be_truthy }
        end
      end

    end
  end
end
