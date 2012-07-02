require 'spec_helper'

describe TaxonConcept do
  context "Falconiformes" do
    include_context "Falconiformes"

    context "LISTING" do
      describe :current_listing do
        it "should be I/II/III/NC at order level Falconiformes" do
          @order.current_listing.should == 'I/II/III/NC'
        end
        it "should be I at species level Falco araea" do
          @species2_1.current_listing.should == 'I'
        end
        it "should be II at species level Falco alopex (H)" do
          @species2_2.current_listing.should == 'II'
        end
        it "should be I at species level Gymnogyps californianus" do
          @species1_1.current_listing.should == 'I'
        end
        it "should be III at species level Sarcoramphus papa" do
          @species1_2.current_listing.should == 'III'
        end
      end

      describe :cites_listed do
        it "should be true for order Falconiformes" do
          @order.cites_listed.should be_true
        end
        it "should be false for family Falconidae (inclusion in higher taxa listing)" do
          @family2.cites_listed.should be_false
        end
        it "should be false for genus Falco" do
          @genus2_1.cites_listed.should be_false
        end
        it "should be true for species Falco araea" do
          @species2_1.cites_listed.should be_true
        end
        it "should be false for species Falco alopex" do
          @species2_2.cites_listed.should be_false
        end
      end

    end
  end
end