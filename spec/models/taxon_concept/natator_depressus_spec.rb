require 'spec_helper'

describe TaxonConcept do
  context "Natator depressus" do
    include_context "Natator depressus"

    context "LISTING" do
      describe :cites_listing do
        context "for family Cheloniidae" do
          specify { expect(@family.cites_listing).to eq('I') }
        end
        context "for species Natator depressus" do
          specify { expect(@species.cites_listing).to eq('I') }
        end
      end

    end

  end
end
