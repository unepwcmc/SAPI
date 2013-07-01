require 'spec_helper'

describe TaxonConcept do
  context "Canis lupus" do
    include_context "Canis lupus"
    context "LISTING" do
      describe :cites_listing do
        context "for species Canis lupus (population split listing)" do
          specify{ @species.cites_listing.should == 'I/II' }
        end
      end

      describe :eu_listing do
        context "for species Canis lupus (population split listing)" do
          specify{ @species.eu_listing.should == 'A/B' }
        end
      end

      describe :cites_listed do
        context "for species Canis lupus" do
          specify{ @species.cites_listed.should be_true }
        end
      end

      describe :eu_listed do
        context "for species Canis lupus" do
          specify{ @species.eu_listed.should be_true }
        end
      end

    end
  end
end
