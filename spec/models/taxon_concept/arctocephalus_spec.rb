require 'spec_helper'

describe TaxonConcept do
  context "Arctocephalus" do
    include_context :designations
    include_context :ranks
    include_context "Arctocephalus"

    context "LISTING" do
      describe :current_listing do
        it "should be II at species level Arctocephalus australis" do
          @species1.current_listing.should == 'II'
        end
        it "should be I at species level Arctocephalus townsendi" do
          @species2.current_listing.should == 'I'
        end
        it "should be I/II at genus level Arctocephalus" do
          @genus.current_listing.should == 'I/II'
        end
      end

      describe :cites_listed do
        it "should be true for genus Arctocephalus" do
          @genus.cites_listed.should be_true
        end
        it "should be true for species Arctocephalus townsendi" do
          @species2.cites_listed.should be_true
        end
        it "should be false for species Arctocephalus australis (inclusion in higher taxa listing)" do
          @species1.cites_listed.should == false
        end
      end

      describe :closest_listed_ancestor do
        context "for genus Arctocephalus" do
          specify{ @genus.closest_listed_ancestor.should == @genus }
        end
        context "for species Arctocephalus australis" do
          specify{ @species1.closest_listed_ancestor.should == @genus }
        end
      end

      describe :closest_listed_ancestor_id do
        context "for genus Arctocephalus" do
          specify{ @genus.closest_listed_ancestor_id.should == @genus.id }
        end
        context "for species Arctocephalus australis" do
          specify{ @species1.closest_listed_ancestor_id.should == @genus.id }
        end
      end

    end
  end
end