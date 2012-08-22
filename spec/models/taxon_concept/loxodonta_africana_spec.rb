require 'spec_helper'

describe TaxonConcept do
  context "Loxodonta africana" do
    include_context "Loxodonta africana"
    context "TAXONOMY" do
      describe :full_name do
        it "should be binomen for species: Loxodonta africana" do
          @species.full_name.should == 'Loxodonta africana'
        end
        it "should be single name for genus: Loxodonta" do
          @genus.full_name.should == 'Loxodonta'
        end
      end
      describe :rank do
        it "should be SPECIES" do
          @species.rank_name.should == 'SPECIES'
        end
      end
      describe :parents do
        it "should have Elephantidae as family" do
          @species.family_name == 'Elephantidae'
        end
        it "should have Proboscidea as order" do
          @species.order_name == 'Proboscidea'
        end
        it "should have Mammalia as class" do
          @species.class_name == 'Mammalia'
        end
      end
    end

    context "LISTING" do
      describe :current_listing do
        it "should be I/II at species level Loxodonta africana (population split listing)" do
          @species.current_listing.should == 'I/II'
        end
      end

      describe :cites_listed do
        it "should be true for species Loxodonta africana" do
          @species.cites_listed.should be_true
        end
        it "should be false for family Elephantidae" do
          @family.cites_listed.should be_false
        end
      end

      describe :cites_listed_children do
        it "should be true for family Elephantidae" do
          @family.cites_listed_children.should be_true
        end
        it "should be true for order Proboscidea" do
          @order.cites_listed_children.should be_true
        end
        it "should be true for class Mammalia" do
          @klass.cites_listed_children.should be_true
        end
      end

    end
  end
end