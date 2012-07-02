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

      describe :cites_listed do
        it "should be true for family Tapiridae" do
          @family.cites_listed.should be_true
        end
        it "should be false for genus Tapirus" do
          @genus.cites_listed.should be_false
        end
        it "should be trye for species Tapirus terrestris" do
          @species.cites_listed.should be_true
        end
      end

    end
  end
end