require 'spec_helper'

describe TaxonConcept do
  context "Panax ginseng" do
    include_context "Panax ginseng"

    context "LISTING" do
      describe :current_listing do
        it "should be II/NC at species level Panax ginseng" do
          @species.current_listing.should == 'II/NC'
        end
      end

      describe :cites_listed do
        it "should be false for genus Panax" do
          @genus.cites_listed.should be_false
        end
        it "should be true for species Panax ginseng" do
          @species.cites_listed.should be_true
        end
      end

    end
  end
end