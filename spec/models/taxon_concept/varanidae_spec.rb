#Encoding: utf-8
require 'spec_helper'

describe TaxonConcept do
  context "Varanidae" do
    include_context "Varanidae"

    context "REFERENCES" do
      describe :cites_accepted do
        it "should be true for species Varanus bengalensis" do
          @species1.cites_accepted.should be_true
        end
      end
      describe :standard_references do
        it "should be nil for order Sauria" do
          @order.standard_references.should be_empty
        end
        it "should be Böhme for family Varanidae" do
          @family.standard_references.should include @ref1.id
        end
        it "should be Böhme for species Varanus bengalensis" do
          @species1.standard_references.should include @ref1.id
        end
        it "should be Böhme and Aplin for species Varanus bushi" do
          @species2.standard_references.should include @ref1.id
          @species2.standard_references.should include @ref2.id
        end
      end
    end
    context "LISTING" do
      describe :current_listing do
        it "should be I/II at genus level Varanus" do
          @genus.current_listing.should == 'I/II'
        end
        it "should be I at species level Varanus bengalensis" do
          @species1.current_listing.should == 'I'
        end
      end

      describe :cites_listed do
        it "should be false for family Varanidae" do
          @family.cites_listed.should == false
        end
        it "should be true for genus Varanus" do
          @genus.cites_listed.should be_true
        end
        it "should be true for species Varanus bengalensis" do
          @species1.cites_listed.should be_true
        end
      end

    end
  end
end