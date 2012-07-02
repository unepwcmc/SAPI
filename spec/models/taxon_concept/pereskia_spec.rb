require 'spec_helper'

describe TaxonConcept do
  context "Pereskia" do
    include_context "Pereskia"

    context "LISTING" do
      describe :current_listing do
        it "should be NC at genus level Pereskia (not listed, shown)" do
          @genus1.current_listing.should == 'NC'
        end
        it "should be I at genus level Ariocarpus" do
          @genus2.current_listing.should == 'I'
        end
        it "should be II at family level Cactaceae" do
          @family.current_listing.should == 'I/II/NC'
        end
      end

      describe :cites_listed do
        it "should be true for family Cactaceae" do
          @family.cites_listed.should be_true
        end
        it "should be false for genus Pereskia" do
          @genus1.cites_listed.should be_false
        end
      end

    end
  end
end