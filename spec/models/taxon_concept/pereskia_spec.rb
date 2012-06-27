require 'spec_helper'

describe TaxonConcept do
  context "Pereskia" do
    include_context "Pereskia"

    context "LISTING" do
      describe :current_listing do
        it "should be NC at genus level Pereskia" do
          @genus1.current_listing.should == 'NC'
        end
        it "should be I at genus level Ariocarpus" do
          @genus2.current_listing.should == 'I'
        end
        it "should be II at family level Cactaceae" do
          @family.current_listing.should == 'I/II/NC'
        end
      end
    end
  end
end