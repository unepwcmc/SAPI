require 'spec_helper'

describe TaxonConcept do
  context "Agalychnis" do
    include_context "Agalychnis"

    context "REFERENCES" do
      describe :cites_accepted do
        context "for class Amphibia" do
          specify { expect(@klass.cites_accepted).to be_truthy }
        end
        context "for family Hylidae" do
          specify { expect(@family.cites_accepted).to be_truthy }
        end
        context "for genus Agalychnis" do
          specify { expect(@genus.cites_accepted).to eq(false) }
        end
      end
      describe :standard_taxon_concept_references do
        context "for class Amphibia" do
          specify { expect(@klass.taxon_concept.standard_taxon_concept_references.map(&:reference_id)).to include @ref.id }
        end
        context "for family Hylidae" do
          specify { expect(@family.taxon_concept.standard_taxon_concept_references.map(&:reference_id)).to include @ref.id }
        end
        context "for genus Agalychnis" do
          specify { expect(@genus.taxon_concept.standard_taxon_concept_references).to be_empty }
        end
      end
    end
    context "LISTING" do
      describe :cites_listing do
        context "for genus Agalychnis" do
          specify { expect(@genus.cites_listing).to eq('II') }
        end
      end

      describe :eu_listing do
        context "for genus Agalychnis" do
          specify { expect(@genus.eu_listing).to eq('B') }
        end
      end

      describe :cites_listed do
        context "for family Hylidae" do
          specify { expect(@family.cites_listed).to eq(false) }
        end
        context "for genus Agalychnis" do
          specify { expect(@genus.cites_listed).to be_truthy }
        end
      end

      describe :eu_listed do
        context "for family Hylidae" do
          specify { expect(@family.eu_listed).to eq(false) }
        end
        context "for genus Agalychnis" do
          specify { expect(@genus.eu_listed).to be_truthy }
        end
      end

    end
  end
end
