require 'spec_helper'

describe TaxonConcept do
  context "Natator depressus" do
    include_context "Natator depressus"

    context "LISTING" do
      describe :cites_listing do
        context "for family Cheloniidae" do
          specify { @family.cites_listing.should == 'I' }
        end
        context "for species Natator depressus" do
          specify { @species.cites_listing.should == 'I' }
        end
      end

    end

  end
end
