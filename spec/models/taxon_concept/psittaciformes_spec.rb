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
          specify { @species2_2.cites_listing.should == 'II' }
        end
        context "for species Agapornis roseicollis (DEL II, not listed, not shown)" do
          specify { @species2_1.cites_listing.should == 'NC' }
        end
        context "for species Psittacula krameri (DEL III, not listed, not shown)" do
          specify { @species2_3.cites_listing.should == 'NC' }
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
          specify { @species2_2.eu_listing.should == 'B' }
        end
        context "for species Agapornis roseicollis (DEL II, not listed, not shown)" do
          specify { @species2_1.eu_listing.should == 'NC' }
        end
        context "for species Psittacula krameri (DEL III, not listed, not shown)" do
          specify { @species2_3.eu_listing.should == 'NC' }
        end
      end

      describe :cites_listed do
        context "for order Psittaciformes" do
          specify { @order.cites_listed.should be_true }
        end
        context "for family Cacatuidae" do
          specify { @family1.cites_listed.should == false }
        end
        context "for genus Cacatua" do
          specify { @genus1_2.cites_listed.should == false }
        end
        context "for species Cacatua goffiniana" do
          specify { @species1_2_1.cites_listed.should be_true }
        end
        context "for species Cacatua ducorpsi" do
          specify { @species1_2_2.cites_listed.should == false }
        end
      end

      describe :eu_listed do
        context "for order Psittaciformes" do
          specify { @order.eu_listed.should be_true }
        end
        context "for family Cacatuidae" do
          specify { @family1.eu_listed.should == false }
        end
        context "for genus Cacatua" do
          specify { @genus1_2.eu_listed.should == false }
        end
        context "for species Cacatua goffiniana" do
          specify { @species1_2_1.eu_listed.should be_true }
        end
        context "for species Cacatua ducorpsi" do
          specify { @species1_2_2.eu_listed.should == false }
        end
      end

      describe :cites_show do
        context "for species Agapornis roseicollis (DEL II)" do
          specify { @species2_1.cites_show.should be_false }
        end
        context "for species Amazona aestiva" do
          specify { @species2_2.cites_show.should be_true }
        end
        context "for species Psittacula krameri (DEL III)" do
          specify { @species2_3.cites_show.should be_false }
        end
      end

      describe :cites_status do
        context "for species Agapornis roseicollis (DEL II)" do
          specify { @species2_1.cites_status.should == 'DELETED' }
        end
        context "for species Psittacula krameri (DEL III)" do
          specify { @species2_3.cites_status.should == 'DELETED' }
        end
      end

    end
  end
end
