require 'spec_helper'

describe TaxonConcept do
  context "Caiman latirostris" do
    include_context "Caiman latirostris"

    context "LISTING" do
      describe :current_listing do
        it "should be I/II at species level Caiman latirostris (population split listing)" do
          @species.current_listing.should == 'I/II'
        end
      end

      describe :cites_listed do
        it "should be true for family Crocodylia" do
          @family.cites_listed.should be_true
        end
        it "should be false for genus Caiman" do
          @genus.cites_listed.should be_false
        end
        it "should be true for species Caiman latoristris" do
          @species.cites_listed.should be_true
        end
      end

    end
  end
end