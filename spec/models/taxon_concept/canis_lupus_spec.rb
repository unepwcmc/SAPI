require 'spec_helper'

describe TaxonConcept do
  context "Canis lupus" do
    include_context "Canis lupus"
    context "LISTING" do
      describe :current_listing do
        it "should be I/II/NC at species level Canis lupus (population split listing)" do
          @species.current_listing.should == 'I/II/NC'
        end
      end
    end

      describe :cites_listed do
        it "should be true for species Canis lupus" do
          @species.cites_listed.should be_true
        end
      end

  end
end