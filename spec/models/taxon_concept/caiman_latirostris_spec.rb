require 'spec_helper'
require Rails.root.join("spec/models/shared/caiman_latirostris")

describe TaxonConcept do
  context "Caiman latirostris" do
    include_context "Caiman latirostris"

    context "LISTING" do
      describe :current_listing do
        it "should be I/II at species level Caiman latirostris" do
          @species.current_listing.should == 'I/II'
        end
      end
    end
  end
end