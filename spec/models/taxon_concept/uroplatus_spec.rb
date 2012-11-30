#Encoding: utf-8
require 'spec_helper'

describe TaxonConcept do
  context "Uroplatus" do
    include_context "Uroplatus"

    context "REFERENCES" do
      describe :cites_accepted do
        context "for genus Uroplatus" do
          specify { @genus.cites_accepted.should == false }
        end
        context "for species Uroplatus alluaudi" do
          specify { @species1.cites_accepted.should == false }
        end
        context "for species Uroplatus giganteus" do
          specify { @species2.cites_accepted.should be_true }
        end
      end
      describe :standard_references do
        context "for family Gekkonidae" do
          specify { @family.standard_references.should be_empty }
        end
        context "for genus Uroplatus" do
          specify { @genus.standard_references.should be_empty }
        end
        context "for species Uroplatus alluaudi" do
          specify { @species1.standard_references.should be_empty }
        end
        context "for species Uroplatus giganteus" do
          specify { @species2.standard_references.should include @ref.id }
        end
      end
    end
    context "LISTING" do
      describe :current_listing do
        context "for genus Uroplatus" do
          specify { @genus.current_listing.should == 'II' }
        end
        context "for species Uroplatus giganteus" do
          specify { @species2.current_listing.should == 'II' }
        end
      end

      describe :cites_listed do
        context "for family Gekkonidae" do
          specify { @family.cites_listed.should == false }
        end
        context "for genus Uroplatus" do
          specify { @genus.cites_listed.should be_true }
        end
        context "for species Uroplatus giganteus" do
          specify { @species2.cites_listed.should == false }
        end
      end

    end
  end
end