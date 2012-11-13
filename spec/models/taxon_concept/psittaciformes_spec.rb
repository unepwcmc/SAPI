require 'spec_helper'

describe TaxonConcept do
  context "Psittaciformes" do
    include_context "Psittaciformes"

    context "LISTING" do
      describe :current_listing do
        context "should be I/II/NC at order level Psittaciformes" do
          specify { @order.current_listing.should == 'I/II/NC' }
        end
        context "should be I at species level Cacatua goffiniana" do
          specify { @species1_2_1.current_listing.should == 'I' }
        end
        context "should be II at species level Cacatua ducorpsi (H)" do
          specify { @species1_2_2.current_listing.should == 'II' }
        end
        context "should be I at species level Probosciger aterrimus" do
          specify { @species1_1.current_listing.should == 'I' }
        end
        context "should be II at species level Amazona aestiva" do
          specify { @species2_2.current_listing.should == 'II' }
        end
        context "should be blank at species level Agapornis roseicollis (DEL II, not listed, not shown)" do
          specify { @species2_1.current_listing.should == 'NC' }
        end
        context "should be blank at species level Psittacula krameri (DEL III, not listed, not shown)" do
          specify { @species2_1.current_listing.should == 'NC' }
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

      describe :cites_show do
        context "for species Agapornis roseicollis (DEL II)" do
          specify { @species2_1.cites_show.should_not be_true }
        end
        context "for species Amazona aestiva" do
          specify { @species2_2.cites_show.should be_true }
        end
        context "for species Psittacula krameri (DEL III)" do
          specify { @species2_3.cites_show.should_not be_true }
        end
      end

      describe :cites_deleted do
        context "for species Agapornis roseicollis (DEL II)" do
          specify { @species2_1.cites_deleted.should be_true }
        end
        context "for species Amazona aestiva" do
          specify { @species2_2.cites_deleted.should == false }
        end
        context "for species Psittacula krameri (DEL III)" do
          specify { @species2_3.cites_deleted.should be_true }
        end
      end

      describe :cites_fully_covered do
        context "for family Psittacidae" do
          specify { @family2.cites_fully_covered.should_not be_true }
        end
        context "for order Psittaciformes" do
          specify { @order.cites_fully_covered.should_not be_true }
        end
      end

    end
  end
end