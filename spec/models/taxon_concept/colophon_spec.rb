require 'spec_helper'

describe TaxonConcept do
  context "Colophon" do
    include_context "Colophon"

    context "LISTING" do
      describe :cites_listing do
        context "for genus Colophon" do
          specify { expect(@genus.cites_listing).to eq('III') }
        end
        context "for species Colophon barnardi" do
          specify { expect(@species.cites_listing).to eq('III') }
        end
      end

      describe :eu_listing do
        context "for genus Colophon" do
          specify { expect(@genus.eu_listing).to eq('C') }
        end
        context "for species Colophon barnardi" do
          specify { expect(@species.eu_listing).to eq('C') }
        end
      end

      describe :cites_listed do
        context "for genus Colophon" do
          specify { expect(@genus.cites_listed).to eq(true) }
        end
        context "for species Colophon barnardi" do
          specify { expect(@species.cites_listed).to eq(false) }
        end
      end

      describe :eu_listed do
        context "for genus Colophon" do
          specify { expect(@genus.eu_listed).to eq(true) }
        end
        context "for species Colophon barnardi" do
          specify { expect(@species.eu_listed).to eq(false) }
        end
      end

      describe :cites_show do
        context "for order Coleoptera" do
          specify { expect(@order.cites_show).to be_falsey }
        end
        context "for family Lucanidae" do
          specify { expect(@family.cites_show).to be_falsey }
        end
      end

      describe :current_party_ids do
        context "for genus Colophon" do
          specify { expect(@genus.current_parties_ids).to eq([GeoEntity.find_by_iso_code2('ZA').id]) }
        end
        context "for species Colophon barnardi" do
          specify { expect(@species.current_parties_ids).to eq([GeoEntity.find_by_iso_code2('ZA').id]) }
        end
      end

    end
  end
end
