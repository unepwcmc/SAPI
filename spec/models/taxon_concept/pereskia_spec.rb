require 'spec_helper'

describe TaxonConcept do
  context "Pereskia" do
    include_context "Pereskia"

    context "LISTING" do
      describe :cites_listing do
        context "for genus Pereskia (not listed, shown)" do
          specify { @genus1.cites_listing.should == 'NC' }
        end
        context "for genus Ariocarpus" do
          specify { @genus2.cites_listing.should == 'I' }
        end
        context "for family Cactaceae" do
          specify { @family.cites_listing.should == 'I/II/NC' }
        end
      end

      describe :eu_listing do
        context "for genus Pereskia (not listed, shown)" do
          specify { @genus1.eu_listing.should == 'NC' }
        end
        context "for genus Ariocarpus" do
          specify { @genus2.eu_listing.should == 'A' }
        end
        context "for family Cactaceae" do
          specify { @family.eu_listing.should == 'A/B/NC' }
        end
      end

      describe :cites_listed do
        context "for family Cactaceae" do
          specify { @family.cites_listed.should be_truthy }
        end
        context "for genus Pereskia" do
          specify { @genus1.cites_listed.should be_nil }
        end
      end

      describe :eu_listed do
        context "for family Cactaceae" do
          specify { @family.eu_listed.should be_truthy }
        end
        context "for genus Pereskia" do
          specify { @genus1.eu_listed.should be_nil }
        end
      end

      describe :cites_status do
        context "for genus Pereskia" do
          specify { @genus1.cites_status.should == 'EXCLUDED' }
        end
      end

      describe :cites_show do
        context "for genus Pereskia" do
          specify { @genus1.cites_show.should == true }
        end
      end

    end
  end
end
