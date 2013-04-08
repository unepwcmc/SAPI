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
        it "should be false for genus Ailuropoda" do
          @genus.cites_listed.should be_false
        end
        it "should be true for species Ailuropoda melanoleuca" do
          @species.cites_listed.should be_true
        end
      end

      describe :eu_listed do
        it "should be false for genus Ailuropoda" do
          @genus.eu_listed.should be_false
        end
        it "should be true for species Ailuropoda melanoleuca" do
          @species.eu_listed.should be_true
        end
      end

      describe :cites_closest_listed_ancestor_id do
        context "for genus Ailuropoda" do
          specify{ @genus.cites_closest_listed_ancestor_id.should == @family.id }
        end
        context "for species Ailuropoda melanoleuca" do
          specify{ @species.cites_closest_listed_ancestor_id.should == @species.id }
        end
      end

      describe :eu_closest_listed_ancestor_id do
        context "for genus Ailuropoda" do
          specify{ @genus.eu_closest_listed_ancestor_id.should == @family.id }
        end
        context "for species Ailuropoda melanoleuca" do
          specify{ @species.eu_closest_listed_ancestor_id.should == @species.id }
        end
      end

    end
  end
end