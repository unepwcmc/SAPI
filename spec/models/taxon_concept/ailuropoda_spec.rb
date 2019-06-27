require 'spec_helper'

describe TaxonConcept do
  context "Ailuropoda" do
    include_context "Ailuropoda"

    context "LISTING" do
      describe :cites_listing do
        context "for species Ailuropoda melanoleuca" do
          specify { @species.cites_listing.should == 'I' }
        end
        context "for genus level Ailuropoda" do
          specify { @genus.cites_listing.should == 'I' }
        end
      end

      describe :eu_listing do
        context "for species Ailuropoda melanoleuca" do
          specify { @species.eu_listing.should == 'A' }
        end
        context "for genus level Ailuropoda" do
          specify { @genus.eu_listing.should == 'A' }
        end
      end

      describe :cites_listed do
        context "for genus Ailuropoda" do
          specify { @genus.cites_listed.should be_falsey }
        end
        context "for species Ailuropoda melanoleuca" do
          specify { @species.cites_listed.should be_truthy }
        end
      end

      describe :eu_listed do
        context "for genus Ailuropoda" do
          specify { @genus.eu_listed.should be_falsey }
        end
        context "for species Ailuropoda melanoleuca" do
          specify { @species.eu_listed.should be_truthy }
        end
      end

    end
  end
end
