require 'spec_helper'

describe TaxonConcept do
  context "Ailuropoda" do
    include_context "Ailuropoda"

    context "LISTING" do
      describe :current_listing do
        it "should be I at species level Ailuropoda melanoleuca" do
          @species.current_listing.should == 'I'
        end
        it "should be I at genus level Ailuropoda" do
          @genus.current_listing.should == 'I'
        end
      end

      describe :cites_listed do
        it "should be true for genus Ailuropoda" do
          @genus.cites_listed.should be_false
        end
        it "should be true for species Ailuropoda melanoleuca" do
          @species.cites_listed.should be_true
        end
      end

      describe :closest_listed_ancestor do
        context "for genus Ailuropoda" do
          specify{ @genus.closest_listed_ancestor.should == @family }
        end
        context "for species Ailuropoda melanoleuca" do
          specify{ @species.closest_listed_ancestor.should == @species }
        end
      end

      describe :closest_listed_ancestor_id do
        context "for genus Ailuropoda" do
          specify{ @genus.closest_listed_ancestor_id.should == @family.id }
        end
        context "for species Ailuropoda melanoleuca" do
          specify{ @species.closest_listed_ancestor_id.should == @species.id }
        end
      end

    end
  end
end