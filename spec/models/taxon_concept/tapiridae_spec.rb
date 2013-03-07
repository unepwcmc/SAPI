require 'spec_helper'

describe TaxonConcept do
  include_context :designations
  include_context :ranks
  context "Tapiridae" do
    include_context "Tapiridae"
    context "TAXONOMY" do
      describe :full_name do
        context "for family Tapiridae" do
          specify { @family.full_name.should == 'Tapiridae' }
        end
      end
      describe :rank do
        context "for Family" do
          specify { @family.rank_name.should == 'FAMILY' }
        end
      end
      describe :parents do
        context "for species Tapirus terrestris" do
          specify { @species.order_name == 'Perissodactyla' }
        end
        context "for species Tapirus terrestris" do
          specify { @species.class_name == 'Mammalia' }
        end
      end
    end

    context "LISTING" do
      describe :current_listing do
        context "for family Tapiridae" do
          specify { @family.current_listing.should == 'I/II' }
        end
        context "for species Tapirus terrestris" do
          specify { @species.current_listing.should == 'II' }
        end
      end

      describe :cites_listed do
        context "for family Tapiridae" do
          specify { @family.cites_listed.should be_true }
        end
        context "for genus Tapirus" do
          specify { @genus.cites_listed.should == false }
        end
        context "for species Tapirus terrestris" do
          specify { @species.cites_listed.should be_true }
        end
      end

    end
  end
end