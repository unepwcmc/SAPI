require 'spec_helper'

describe TaxonConcept do
  context "Cervus elaphus" do
    include_context "Cervus elaphus"

    context "TAXONOMY" do
      describe :full_name do
        it "should be trinomen for subspecies: Cervus elaphus bactrianus" do
          @subspecies1.full_name.should == 'Cervus elaphus bactrianus'
        end
        it "should be binomen for species: Cervus elaphus" do
          @species.full_name.should == 'Cervus elaphus'
        end
        it "should be single name for genus: Cervus" do
          @genus.full_name.should == 'Cervus'
        end
      end
    end

    context "LISTING" do
      describe :current_listing do
        it "should be I/II/III/NC at species level Cervus elaphus" do
          @species.current_listing.should == 'I/II/III/NC'
        end
        it "should be II at subspecies level Cervus elaphus bactrianus" do
          @subspecies1.current_listing.should == 'II'
        end
        it "should be III at subspecies level Cervus elaphus barbarus" do
          @subspecies2.current_listing.should == 'III'
        end
        it "should be I at subspecies level Cervus elaphus hanglu" do
          @subspecies3.current_listing.should == 'I'
        end
      end
      describe :cites_listed do
        it "should be false for order Artiodactyla" do
          @order.cites_listed.should be_false
        end
        it "should be false for family Cervidae" do
          @family.cites_listed.should be_false
        end
        it "should be false for genus Cervus" do
          @genus.cites_listed.should be_false
        end
        it "should be false for species Cervus elaphus" do
          @species.cites_listed.should be_false
        end
        it "should be true for subspecies Cervus elaphus bactrianus" do
          @subspecies1.cites_listed.should be_true
        end
        it "should be true for subspecies Cervus elaphus barbarus" do
          @subspecies2.cites_listed.should be_true
        end
        it "should be true for subspecies Cervus elaphus hanglu" do
          @subspecies3.cites_listed.should be_true
        end
      end
    end
  end
end