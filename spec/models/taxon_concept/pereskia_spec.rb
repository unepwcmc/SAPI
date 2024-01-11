require 'spec_helper'

describe TaxonConcept do
  context "Pereskia" do
    include_context "Pereskia"

    context "LISTING" do
      describe :cites_listing do
        context "for genus Pereskia (not listed, shown)" do
          specify { expect(@genus1.cites_listing).to eq('NC') }
        end
        context "for genus Ariocarpus" do
          specify { expect(@genus2.cites_listing).to eq('I') }
        end
        context "for family Cactaceae" do
          specify { expect(@family.cites_listing).to eq('I/II/NC') }
        end
      end

      describe :eu_listing do
        context "for genus Pereskia (not listed, shown)" do
          specify { expect(@genus1.eu_listing).to eq('NC') }
        end
        context "for genus Ariocarpus" do
          specify { expect(@genus2.eu_listing).to eq('A') }
        end
        context "for family Cactaceae" do
          specify { expect(@family.eu_listing).to eq('A/B/NC') }
        end
      end

      describe :cites_listed do
        context "for family Cactaceae" do
          specify { expect(@family.cites_listed).to be_truthy }
        end
        context "for genus Pereskia" do
          specify { expect(@genus1.cites_listed).to be_nil }
        end
      end

      describe :eu_listed do
        context "for family Cactaceae" do
          specify { expect(@family.eu_listed).to be_truthy }
        end
        context "for genus Pereskia" do
          specify { expect(@genus1.eu_listed).to be_nil }
        end
      end

      describe :cites_status do
        context "for genus Pereskia" do
          specify { expect(@genus1.cites_status).to eq('EXCLUDED') }
        end
      end

      describe :cites_show do
        context "for genus Pereskia" do
          specify { expect(@genus1.cites_show).to eq(true) }
        end
      end

    end
  end
end
