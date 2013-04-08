require 'spec_helper'

describe TaxonConcept do
  context "Pereskia" do
    include_context "Pereskia"

    context "LISTING" do
      describe :current_listing do
        context "for genus Pereskia (not listed, shown)" do
          specify { @genus1.current_listing.should == 'NC' }
        end
        context "for genus Ariocarpus" do
          specify { @genus2.current_listing.should == 'I' }
        end
        context "for family Cactaceae" do
          specify { @family.current_listing.should == 'I/II/NC' }
        end
      end

      describe :cites_listed do
        context "for family Cactaceae" do
          specify { @family.cites_listed.should be_true }
        end
        context "for genus Pereskia" do
          specify { @genus1.cites_listed.should be_nil }
        end
      end

      describe :eu_listed do
        context "for family Cactaceae" do
          specify { @family.eu_listed.should be_true }
        end
        context "for genus Pereskia" do
          specify { @genus1.eu_listed.should be_nil }
        end
      end

      describe :cites_excluded do
        context "for genus Pereskia" do
          specify { @genus1.cites_excluded.should be_true }
        end
      end

    end
  end
end