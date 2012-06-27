require 'spec_helper'

describe TaxonConcept do
  context "Tapiridae" do
    include_context "Tapiridae"
    context "TAXONOMY" do
      describe :full_name do
        it "should be single name for family: Tapiridae" do
          @family.full_name.should == 'Tapiridae'
        end
      end
      describe :rank do
        it "should be Family" do
          @family.rank_name.should == 'FAMILY'
        end
      end
      describe :parents do
        it "should have Perissodactyla as order" do
          @species.order_name == 'Perissodactyla'
        end
        it "should have Mammalia as class" do
          @species.class_name == 'Mammalia'
        end
      end
    end

    context "LISTING" do
      describe :current_listing do
        it "should be I/II at family level Tapiridae" do
          @family.current_listing.should == 'I/II'
        end
        it "should be II at species level Tapirus terrestris" do
          @species.current_listing.should == 'II'
        end
      end
    end
  end
end