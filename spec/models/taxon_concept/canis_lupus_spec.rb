require 'spec_helper'

describe TaxonConcept do
  context "Canis lupus" do
    include_context "Canis lupus"
    context "LISTING" do
      describe :current_listing do
        it "should be II at species level Canis lupus" do
          @species.current_listing.should == 'I/II/NC'
        end
      end
    end
  end
end