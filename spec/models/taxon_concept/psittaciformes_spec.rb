require 'spec_helper'

describe TaxonConcept do
  context "Psittaciformes" do
    include_context "Psittaciformes"

    context "LISTING" do
      describe :current_listing do
        it "should be I/II/NC at order level Psittaciformes" do
          @order.current_listing.should == 'I/II/NC'
        end
        it "should be I at species level Cacatua goffiniana" do
          @species1_2_1.current_listing.should == 'I'
        end
        it "should be II at species level Cacatua ducorpsi (H)" do
          @species1_2_2.current_listing.should == 'II'
        end
        it "should be I at species level Probosciger aterrimus" do
          @species1_1.current_listing.should == 'I'
        end
        it "should be II at species level Amazona aestiva" do
          @species2_2.current_listing.should == 'II'
        end
        it "should be blank at species level Agapornis roseicollis (DEL II, not listed, not shown)" do
          @species2_1.current_listing.should be_blank
        end
        it "should be blank at species level Psittacula krameri (DEL III, not listed, not shown)" do
          @species2_1.current_listing.should be_blank
        end
      end

      describe :cites_listed do
        it "should be true for order Psittaciformes" do
          @order.cites_listed.should be_true
        end
        it "should be false for family Cacatuidae" do
          @family1.cites_listed.should be_false
        end
        it "should be false for genus Cacatua" do
          @genus1_2.cites_listed.should be_false
        end
        it "should be true for species Cacatua goffiniana" do
          @species1_2_1.cites_listed.should be_true
        end
        it "should be false for species Cacatua ducorpsi" do
          @species1_2_2.cites_listed.should be_false
        end
      end

      describe :cites_show do
        it "should not show Agapornis roseicollis (DEL II)" do
          @species2_1.cites_show.should_not be_true
        end
        it "should show Amazona aestiva" do
          @species2_2.cites_show.should be_true
        end
        it "should not show Psittacula krameri (DEL III)" do
          @species2_3.cites_show.should_not be_true
        end
      end

      describe :cites_del do
        it "should be true for Agapornis roseicollis (DEL II)" do
          @species2_1.cites_del.should be_true
        end
        it "should be false for Amazona aestiva" do
          @species2_2.cites_del.should be_false
        end
        it "should be true for Psittacula krameri (DEL III)" do
          @species2_3.cites_del.should be_true
        end
      end

      describe :cites_nc do
        it "should be true for Agapornis roseicollis (DEL II)" do
          @species2_1.cites_nc.should be_true
        end
        it "should be false for Amazona aestiva" do
          @species2_2.cites_nc.should be_false
        end
        it "should be true for Psittacula krameri (DEL III)" do
          @species2_3.cites_nc.should be_true
        end
      end

    end
  end
end