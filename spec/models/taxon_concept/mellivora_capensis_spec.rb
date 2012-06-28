require 'spec_helper'

describe TaxonConcept do
  context "Mellivora capensis" do
    include_context "Mellivora capensis"
    context "LISTING" do
      describe :current_listing do
        it "should be III at species level Mellivora capensis" do
          @species.current_listing.should == 'III'
        end
      end
    end
  end
end