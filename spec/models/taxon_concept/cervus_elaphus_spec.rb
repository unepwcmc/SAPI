require 'spec_helper'

describe TaxonConcept do
  context "Cervus elaphus" do
    include_context "Cervus elaphus"

    context "TAXONOMY" do
      describe :full_name do
        context "for subspecies Cervus elaphus bactrianus" do
          specify { expect(@subspecies1.full_name).to eq('Cervus elaphus bactrianus') }
        end
        context "for species Cervus elaphus" do
          specify { expect(@species.full_name).to eq('Cervus elaphus') }
        end
        context "for genus Cervus" do
          specify { expect(@genus.full_name).to eq('Cervus') }
        end
      end
    end

    context "LISTING" do
      describe :cites_listing do
        context "for species Cervus elaphus" do
          specify { expect(@species.cites_listing).to eq('I/II/III/NC') }
        end
        context "for subspecies Cervus elaphus bactrianus" do
          specify { expect(@subspecies1.cites_listing).to eq('II') }
        end
        context "for subspecies Cervus elaphus barbarus" do
          specify { expect(@subspecies2.cites_listing).to eq('III') }
        end
        context "for subspecies Cervus elaphus hanglu" do
          specify { expect(@subspecies3.cites_listing).to eq('I') }
        end
        context "for subspecies Cervus elaphus canadensis" do
          specify { expect(@subspecies4.cites_listing).to eq('NC') }
        end
      end

      describe :eu_listing do
        context "for species Cervus elaphus" do
          specify { expect(@species.eu_listing).to eq('A/B/C/NC') }
        end
        context "for subspecies Cervus elaphus bactrianus" do
          specify { expect(@subspecies1.eu_listing).to eq('B') }
        end
        context "for subspecies Cervus elaphus barbarus" do
          specify { expect(@subspecies2.eu_listing).to eq('C') }
        end
        context "for subspecies Cervus elaphus hanglu" do
          specify { expect(@subspecies3.eu_listing).to eq('A') }
        end
        context "for subspecies Cervus elaphus canadensis" do
          specify { expect(@subspecies4.eu_listing).to eq('NC') }
        end
      end

      describe :cites_listed do
        context "for order Artiodactyla" do
          specify { expect(@order.cites_listed).to eq(false) }
        end
        context "for family Cervidae" do
          specify { expect(@family.cites_listed).to eq(false) }
        end
        context "for genus Cervus" do
          specify { expect(@genus.cites_listed).to eq(false) }
        end
        context "for species Cervus elaphus" do
          specify { expect(@species.cites_listed).to eq(false) }
        end
        context "for subspecies Cervus elaphus bactrianus" do
          specify { expect(@subspecies1.cites_listed).to be_truthy }
        end
        context "for subspecies Cervus elaphus barbarus" do
          specify { expect(@subspecies2.cites_listed).to be_truthy }
        end
        context "for subspecies Cervus elaphus hanglu" do
          specify { expect(@subspecies3.cites_listed).to be_truthy }
        end
        context "for subspecies Cervus elaphus canadensis" do
          specify { expect(@subspecies4.cites_listed).to be_blank }
        end
      end

      describe :eu_listed do
        context "for order Artiodactyla" do
          specify { expect(@order.eu_listed).to eq(false) }
        end
        context "for family Cervidae" do
          specify { expect(@family.eu_listed).to eq(false) }
        end
        context "for genus Cervus" do
          specify { expect(@genus.eu_listed).to eq(false) }
        end
        context "for species Cervus elaphus" do
          specify { expect(@species.eu_listed).to eq(false) }
        end
        context "for subspecies Cervus elaphus bactrianus" do
          specify { expect(@subspecies1.eu_listed).to be_truthy }
        end
        context "for subspecies Cervus elaphus barbarus" do
          specify { expect(@subspecies2.eu_listed).to be_truthy }
        end
        context "for subspecies Cervus elaphus hanglu" do
          specify { expect(@subspecies3.eu_listed).to be_truthy }
        end
        context "for subspecies Cervus elaphus canadensis" do
          specify { expect(@subspecies4.eu_listed).to be_blank }
        end
      end

      describe :cites_show do
        context "for subspecies Cervus elaphus hanglu" do
          specify { expect(@subspecies3.cites_show).to be_truthy }
        end
        context "for subspecies Cervus elaphus canadensis" do
          specify { expect(@subspecies4.cites_show).to be_falsey }
        end
      end

    end
  end
end
