require 'spec_helper'

describe TaxonConcept do
  context "Tapiridae" do
    include_context "Tapiridae"
    context "TAXONOMY" do
      describe :full_name do
        context "for family Tapiridae" do
          specify { @family.full_name.should == 'Tapiridae' }
        end
      end
      describe :rank do
        context "for family Tapiridae" do
          specify { @family.rank_name.should == 'FAMILY' }
        end
      end
      describe :ancestors do
        context "order" do
          specify { @species.order_name == 'Perissodactyla' }
        end
        context "class" do
          specify { @species.class_name == 'Mammalia' }
        end
      end
    end

    context "LISTING" do
      describe :cites_listing do
        context "for family Tapiridae" do
          specify { @family.cites_listing.should == 'I/II' }
        end
        context "for species Tapirus terrestris" do
          specify { @species.cites_listing.should == 'II' }
        end
      end

      describe :eu_listing do
        context "for family Tapiridae" do
          specify { @family.eu_listing.should == 'A/B' }
        end
        context "for species Tapirus terrestris" do
          specify { @species.eu_listing.should == 'B' }
        end
      end

      describe :cites_listed do
        context "for family Tapiridae" do
          specify { @family.cites_listed.should be_truthy }
        end
        context "for genus Tapirus" do
          specify { @genus.cites_listed.should == false }
        end
        context "for species Tapirus terrestris" do
          specify { @species.cites_listed.should be_truthy }
        end
      end

      describe :eu_listed do
        context "for family Tapiridae" do
          specify { @family.eu_listed.should be_truthy }
        end
        context "for genus Tapirus" do
          specify { @genus.eu_listed.should == false }
        end
        context "for species Tapirus terrestris" do
          specify { @species.eu_listed.should be_truthy }
        end
      end
    end
  end
end
