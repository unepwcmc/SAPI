require 'spec_helper'

describe TaxonConcept do
  context "Psittaciformes" do
    include_context "Psittaciformes"

    context "LISTING" do
      describe :cites_listing do
        context "for order Psittaciformes" do
          specify { @order.cites_listing.should == 'I/II/NC' }
        end
        context "for species Cacatua goffiniana" do
          specify { @species1_2_1.cites_listing.should == 'I' }
        end
        context "for species Cacatua ducorpsi (H)" do
          specify { @species1_2_2.cites_listing.should == 'II' }
        end
        context "for species Probosciger aterrimus" do
          specify { @species1_1.cites_listing.should == 'I' }
        end
        context "for species Amazona aestiva" do
          specify { @species2_2_1.cites_listing.should == 'II' }
        end
        context "for species Agapornis roseicollis (DEL II, not listed, not shown)" do
          specify { @species2_1.cites_listing.should == 'NC' }
        end
        context "for species Psittacula krameri (DEL III, not listed, not shown)" do
          specify { @species2_3.cites_listing.should == 'NC' }
        end
        context "for subspecies Amazona festiva festiva" do
          specify { @subspecies2_2_2_1.cites_listing.should == 'II' }
        end
      end

      describe :eu_listing do
        context "for order Psittaciformes" do
          specify { @order.eu_listing.should == 'A/B/NC' }
        end
        context "for species Cacatua goffiniana" do
          specify { @species1_2_1.eu_listing.should == 'A' }
        end
        context "for species Cacatua ducorpsi (H)" do
          specify { @species1_2_2.eu_listing.should == 'B' }
        end
        context "for species Probosciger aterrimus" do
          specify { @species1_1.eu_listing.should == 'A' }
        end
        context "for species Amazona aestiva" do
          specify { @species2_2_1.eu_listing.should == 'B' }
        end
        context "for species Agapornis roseicollis (DEL II, not listed, not shown)" do
          specify { @species2_1.eu_listing.should == 'NC' }
        end
        context "for species Psittacula krameri (DEL III, not listed, not shown)" do
          specify { @species2_3.eu_listing.should == 'NC' }
        end
        context "for subspecies Amazona festiva festiva" do
          specify { @subspecies2_2_2_1.eu_listing.should == 'B' }
        end
      end

      describe :cites_listed do
        context "for order Psittaciformes" do
          specify { @order.cites_listed.should be_truthy }
        end
        context "for family Cacatuidae" do
          specify { @family1.cites_listed.should == false }
        end
        context "for genus Cacatua" do
          specify { @genus1_2.cites_listed.should == false }
        end
        context "for species Cacatua goffiniana" do
          specify { @species1_2_1.cites_listed.should be_truthy }
        end
        context "for species Cacatua ducorpsi" do
          specify { @species1_2_2.cites_listed.should == false }
        end
        context "for subspecies Amazona festiva festiva" do
          specify { @subspecies2_2_2_1.cites_listed.should == false }
        end
      end

      describe :eu_listed do
        context "for order Psittaciformes" do
          specify { @order.eu_listed.should be_truthy }
        end
        context "for family Cacatuidae" do
          specify { @family1.eu_listed.should == false }
        end
        context "for genus Cacatua" do
          specify { @genus1_2.eu_listed.should == false }
        end
        context "for species Cacatua goffiniana" do
          specify { @species1_2_1.eu_listed.should be_truthy }
        end
        context "for species Cacatua ducorpsi" do
          specify { @species1_2_2.eu_listed.should == false }
        end
        context "for subspecies Amazona festiva festiva" do
          specify { @subspecies2_2_2_1.eu_listed.should == false }
        end
      end

      describe :cites_show do
        context "for species Agapornis roseicollis (DEL II)" do
          specify { @species2_1.cites_show.should be_truthy }
        end
        context "for species Amazona aestiva" do
          specify { @species2_2_1.cites_show.should be_truthy }
        end
        context "for species Psittacula krameri (DEL III)" do
          specify { @species2_3.cites_show.should be_truthy }
        end
      end

      describe :cites_status do
        context "for species Agapornis roseicollis (DEL II)" do
          specify { @species2_1.cites_status.should == 'EXCLUDED' }
        end
        context "for species Psittacula krameri (DEL III)" do
          specify { @species2_3.cites_status.should == 'EXCLUDED' }
        end
      end

      describe :show_in_checklist_ac do
        context "for subspecies Amazona festiva festiva" do
          specify { @subspecies2_2_2_1_ac.show_in_checklist_ac.should be_falsey }
        end
      end

      describe :show_in_species_plus_ac do
        context "for subspecies Amazona festiva festiva" do
          specify { @subspecies2_2_2_1_ac.show_in_species_plus_ac.should be_falsey }
        end
      end

      describe :show_in_species_plus do
        context "for subspecies Amazona festiva festiva" do
          specify { @subspecies2_2_2_1.show_in_species_plus.should be_falsey }
        end
      end

    end
  end
end
