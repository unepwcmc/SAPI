require 'spec_helper'

describe TaxonConcept do
  context "Arctocephalus" do
    include_context "Arctocephalus"

    context "LISTING" do
      describe :current_listing do
        it "should be II at species level Arctocephalus australis" do
          @species1.current_listing.should == 'II'
        end
        it "should be I at species level Arctocephalus townsendi" do
          @species2.current_listing.should == 'I'
        end
        it "should be I/II at genus level Arctocephalus" do
          @genus.current_listing.should == 'I/II'
        end
      end
    end
  end
end