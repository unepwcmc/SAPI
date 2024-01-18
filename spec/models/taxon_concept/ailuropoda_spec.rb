require 'spec_helper'

describe TaxonConcept do
  context "Ailuropoda" do
    include_context "Ailuropoda"

    context "LISTING" do
      describe :cites_listing do
        context "for species Ailuropoda melanoleuca" do
          specify { expect(@species.cites_listing).to eq('I') }
        end
        context "for genus level Ailuropoda" do
          specify { expect(@genus.cites_listing).to eq('I') }
        end
      end

      describe :eu_listing do
        context "for species Ailuropoda melanoleuca" do
          specify { expect(@species.eu_listing).to eq('A') }
        end
        context "for genus level Ailuropoda" do
          specify { expect(@genus.eu_listing).to eq('A') }
        end
      end

      describe :cites_listed do
        context "for genus Ailuropoda" do
          specify { expect(@genus.cites_listed).to be_falsey }
        end
        context "for species Ailuropoda melanoleuca" do
          specify { expect(@species.cites_listed).to be_truthy }
        end
      end

      describe :eu_listed do
        context "for genus Ailuropoda" do
          specify { expect(@genus.eu_listed).to be_falsey }
        end
        context "for species Ailuropoda melanoleuca" do
          specify { expect(@species.eu_listed).to be_truthy }
        end
      end

    end
  end
end
