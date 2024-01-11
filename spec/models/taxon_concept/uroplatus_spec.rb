require 'spec_helper'

describe TaxonConcept do
  context "Uroplatus" do
    include_context "Uroplatus"

    context "REFERENCES" do
      describe :cites_accepted do
        context "for genus Uroplatus" do
          specify { expect(@genus.cites_accepted).to eq(false) }
        end
        context "for species Uroplatus alluaudi" do
          specify { expect(@species1.cites_accepted).to eq(false) }
        end
        context "for species Uroplatus giganteus" do
          specify { expect(@species2.cites_accepted).to be_truthy }
        end
      end
      describe :standard_taxon_concept_references do
        context "for family Gekkonidae" do
          specify { expect(@family.taxon_concept.standard_taxon_concept_references).to be_empty }
        end
        context "for genus Uroplatus" do
          specify { expect(@genus.taxon_concept.standard_taxon_concept_references.map(&:reference_id)).to be_empty }
        end
        context "for species Uroplatus alluaudi" do
          specify { expect(@species1.taxon_concept.standard_taxon_concept_references.map(&:reference_id)).to be_empty }
        end
        context "for species Uroplatus giganteus" do
          specify { expect(@species2.taxon_concept.standard_taxon_concept_references.map(&:reference_id)).to include @ref.id }
        end
      end
    end
    context "LISTING" do
      describe :cites_listing do
        context "for genus Uroplatus" do
          specify { expect(@genus.cites_listing).to eq('II') }
        end
        context "for species Uroplatus giganteus" do
          specify { expect(@species2.cites_listing).to eq('II') }
        end
      end

      describe :eu_listing do
        context "for genus Uroplatus" do
          specify { expect(@genus.eu_listing).to eq('B') }
        end
        context "for species Uroplatus giganteus" do
          specify { expect(@species2.eu_listing).to eq('B') }
        end
      end

      describe :cites_listed do
        context "for family Gekkonidae" do
          specify { expect(@family.cites_listed).to eq(false) }
        end
        context "for genus Uroplatus" do
          specify { expect(@genus.cites_listed).to be_truthy }
        end
        context "for species Uroplatus giganteus" do
          specify { expect(@species2.cites_listed).to eq(false) }
        end
      end

      describe :eu_listed do
        context "for family Gekkonidae" do
          specify { expect(@family.eu_listed).to eq(false) }
        end
        context "for genus Uroplatus" do
          specify { expect(@genus.eu_listed).to be_truthy }
        end
        context "for species Uroplatus giganteus" do
          specify { expect(@species2.eu_listed).to eq(false) }
        end
      end

    end
  end
end
