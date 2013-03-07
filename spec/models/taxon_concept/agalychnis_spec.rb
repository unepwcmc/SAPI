#Encoding: utf-8
require 'spec_helper'

describe TaxonConcept do
  context "Agalychnis" do
    include_context :designations
    include_context :ranks
    include_context "Agalychnis"

    context "REFERENCES" do
      describe :cites_accepted do
        context "for class Amphibia" do
          specify { @klass.cites_accepted.should be_true }
        end
        context "for family Hylidae" do
          specify { @family.cites_accepted.should be_true }
        end
        context "for genus Agalychnis" do
          specify { @genus.cites_accepted.should == false }
        end
      end
      describe :standard_references do
        context "for class Amphibia" do
          specify { @klass.standard_references.should include @ref.id }
        end
        context "for family Hylidae" do
          specify { @family.standard_references.should include @ref.id }
        end
        context "for genus Agalychnis" do
          specify { @genus.standard_references.should be_empty }
        end
      end
    end
    context "LISTING" do
      describe :current_listing do
        context "for genus Agalychnis" do
          specify { @genus.current_listing.should == 'II' }
        end
      end

      describe :cites_listed do
        context "for family Hylidae" do
          specify { @family.cites_listed.should == false }
        end
        context "for genus Agalychnis" do
          specify { @genus.cites_listed.should be_true }
        end
      end

    end
  end
end