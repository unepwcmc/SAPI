require 'spec_helper'
require Rails.root.join("spec/models/shared/loxodonta_africana")

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
        it "should be I/II at species level Loxodonta africana" do
          @species.current_listing.should == 'I/II'
        end
      end
    end
  end
end