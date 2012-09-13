#Encoding: utf-8
require 'spec_helper'

describe TaxonConcept do
  context "Agalychnis" do
    include_context "Agalychnis"

    context "REFERENCES" do
      describe :cites_accepted do
        it "should be true for class Amphibia" do
          @klass.cites_accepted.should be_true
        end
        it "should be true for family Hylidae" do
          @family.cites_accepted.should be_true
        end
        it "should be false for genus Agalychnis" do
          @genus.cites_accepted.should == false
        end
      end
      describe :standard_references do
        it "should be nil for class Amphibia" do
          @klass.standard_references.should include @ref.id
        end
        it "should be Frost for family Hylidae" do
          @family.standard_references.should include @ref.id
        end
        it "should be empty for genus Agalychnis" do
          @genus.standard_references.should be_empty
        end
      end
    end
    context "LISTING" do
      describe :current_listing do
        it "should be II at genus level Agalychnis" do
          @genus.current_listing.should == 'II'
        end
      end

      describe :cites_listed do
        it "should be false for family Hylidae" do
          @family.cites_listed.should == false
        end
        it "should be true for genus Agalychnis" do
          @genus.cites_listed.should be_true
        end
      end

    end
  end
end