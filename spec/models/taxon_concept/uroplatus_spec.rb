#Encoding: utf-8
require 'spec_helper'

describe TaxonConcept do
  context "Uroplatus" do
    include_context "Uroplatus"

    context "REFERENCES" do
      describe :cites_accepted do
        it "should be false for genus Uroplatus" do
          @genus.cites_accepted.should == false
        end
        it "should be false for species Uroplatus alluaudi" do
          @species1.cites_accepted.should == false
        end
        it "should be true for species Uroplatus giganteus" do
          @species2.cites_accepted.should be_true
        end
      end
      describe :standard_references do
        it "should be nil for family Gekkonidae" do
          @family.standard_references.should be_empty
        end
        it "should be nil for genus Uroplatus" do
          @genus.standard_references.should be_empty
        end
        it "should be nil for species Uroplatus alluaudi" do
          @species1.standard_references.should be_empty
        end
        it "should be Glaw for species Uroplatus giganteus" do
          @species2.standard_references.should include @ref.id
        end
      end
    end
    context "LISTING" do
      describe :current_listing do
        it "should be II at genus level Uroplatus" do
          @genus.current_listing.should == 'II'
        end
        it "should be II at species level Uroplatus giganteus" do
          @species2.current_listing.should == 'II'
        end
      end

      describe :cites_listed do
        it "should be false for family Gekkonidae" do
          @family.cites_listed.should == false
        end
        it "should be true for genus Uroplatus" do
          @genus.cites_listed.should be_true
        end
        it "should be false for species Uroplatus giganteus" do
          @species2.cites_listed.should == false
        end
      end

    end
  end
end