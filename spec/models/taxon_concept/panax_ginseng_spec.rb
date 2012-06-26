require 'spec_helper'
require Rails.root.join("spec/models/shared/panax_ginseng")

describe TaxonConcept do
  context "Panax ginseng" do
    include_context "Panax ginseng"

    context "LISTING" do
      describe :current_listing do
        it "should be II/NC at species level Panax ginseng" do
          @species.current_listing.should == 'II/NC'
        end
      end
    end
  end
end