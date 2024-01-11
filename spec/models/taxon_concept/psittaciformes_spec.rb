require 'spec_helper'

describe TaxonConcept do
  context "Psittaciformes" do
    include_context "Psittaciformes"

    context "LISTING" do
      describe :cites_listing do
        context "for order Psittaciformes" do
          specify { expect(@order.cites_listing).to eq('I/II/NC') }
        end
        context "for species Cacatua goffiniana" do
          specify { expect(@species1_2_1.cites_listing).to eq('I') }
        end
        context "for species Cacatua ducorpsi (H)" do
          specify { expect(@species1_2_2.cites_listing).to eq('II') }
        end
        context "for species Probosciger aterrimus" do
          specify { expect(@species1_1.cites_listing).to eq('I') }
        end
        context "for species Amazona aestiva" do
          specify { expect(@species2_2_1.cites_listing).to eq('II') }
        end
        context "for species Agapornis roseicollis (DEL II, not listed, not shown)" do
          specify { expect(@species2_1.cites_listing).to eq('NC') }
        end
        context "for species Psittacula krameri (DEL III, not listed, not shown)" do
          specify { expect(@species2_3.cites_listing).to eq('NC') }
        end
        context "for subspecies Amazona festiva festiva" do
          specify { expect(@subspecies2_2_2_1.cites_listing).to eq('II') }
        end
      end

      describe :eu_listing do
        context "for order Psittaciformes" do
          specify { expect(@order.eu_listing).to eq('A/B/NC') }
        end
        context "for species Cacatua goffiniana" do
          specify { expect(@species1_2_1.eu_listing).to eq('A') }
        end
        context "for species Cacatua ducorpsi (H)" do
          specify { expect(@species1_2_2.eu_listing).to eq('B') }
        end
        context "for species Probosciger aterrimus" do
          specify { expect(@species1_1.eu_listing).to eq('A') }
        end
        context "for species Amazona aestiva" do
          specify { expect(@species2_2_1.eu_listing).to eq('B') }
        end
        context "for species Agapornis roseicollis (DEL II, not listed, not shown)" do
          specify { expect(@species2_1.eu_listing).to eq('NC') }
        end
        context "for species Psittacula krameri (DEL III, not listed, not shown)" do
          specify { expect(@species2_3.eu_listing).to eq('NC') }
        end
        context "for subspecies Amazona festiva festiva" do
          specify { expect(@subspecies2_2_2_1.eu_listing).to eq('B') }
        end
      end

      describe :cites_listed do
        context "for order Psittaciformes" do
          specify { expect(@order.cites_listed).to be_truthy }
        end
        context "for family Cacatuidae" do
          specify { expect(@family1.cites_listed).to eq(false) }
        end
        context "for genus Cacatua" do
          specify { expect(@genus1_2.cites_listed).to eq(false) }
        end
        context "for species Cacatua goffiniana" do
          specify { expect(@species1_2_1.cites_listed).to be_truthy }
        end
        context "for species Cacatua ducorpsi" do
          specify { expect(@species1_2_2.cites_listed).to eq(false) }
        end
        context "for subspecies Amazona festiva festiva" do
          specify { expect(@subspecies2_2_2_1.cites_listed).to eq(false) }
        end
      end

      describe :eu_listed do
        context "for order Psittaciformes" do
          specify { expect(@order.eu_listed).to be_truthy }
        end
        context "for family Cacatuidae" do
          specify { expect(@family1.eu_listed).to eq(false) }
        end
        context "for genus Cacatua" do
          specify { expect(@genus1_2.eu_listed).to eq(false) }
        end
        context "for species Cacatua goffiniana" do
          specify { expect(@species1_2_1.eu_listed).to be_truthy }
        end
        context "for species Cacatua ducorpsi" do
          specify { expect(@species1_2_2.eu_listed).to eq(false) }
        end
        context "for subspecies Amazona festiva festiva" do
          specify { expect(@subspecies2_2_2_1.eu_listed).to eq(false) }
        end
      end

      describe :cites_show do
        context "for species Agapornis roseicollis (DEL II)" do
          specify { expect(@species2_1.cites_show).to be_truthy }
        end
        context "for species Amazona aestiva" do
          specify { expect(@species2_2_1.cites_show).to be_truthy }
        end
        context "for species Psittacula krameri (DEL III)" do
          specify { expect(@species2_3.cites_show).to be_truthy }
        end
      end

      describe :cites_status do
        context "for species Agapornis roseicollis (DEL II)" do
          specify { expect(@species2_1.cites_status).to eq('EXCLUDED') }
        end
        context "for species Psittacula krameri (DEL III)" do
          specify { expect(@species2_3.cites_status).to eq('EXCLUDED') }
        end
      end

      describe :show_in_checklist_ac do
        context "for subspecies Amazona festiva festiva" do
          specify { expect(@subspecies2_2_2_1_ac.show_in_checklist_ac).to be_falsey }
        end
      end

      describe :show_in_species_plus_ac do
        context "for subspecies Amazona festiva festiva" do
          specify { expect(@subspecies2_2_2_1_ac.show_in_species_plus_ac).to be_falsey }
        end
      end

      describe :show_in_species_plus do
        context "for subspecies Amazona festiva festiva" do
          specify { expect(@subspecies2_2_2_1.show_in_species_plus).to be_falsey }
        end
      end

    end
  end
end
