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

      describe :cites_listed do
        it "should be false for family Mustelinae" do
          @family.cites_listed.should == false
        end
        it "should be false for genus Mellivora" do
          @genus.cites_listed.should == false
        end
        it "should be true for species Mellivora capensis" do
          @species.cites_listed.should be_true
        end
      end

    end
  end
end