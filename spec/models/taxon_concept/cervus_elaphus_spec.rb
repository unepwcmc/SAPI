require 'spec_helper'
require Rails.root.join("spec/models/shared/cervus_elaphus")

describe TaxonConcept do
  context "Cervus elaphus" do
    include_context "Cervus elaphus"

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
    end
  end
end