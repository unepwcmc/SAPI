require 'spec_helper'

describe TaxonConcept do
  context "Panax ginseng" do
    include_context "Panax ginseng"

    context "LISTING" do

      describe :cites_listed do
        context "for species Panax ginseng" do
          specify { @species.cites_listed.should be_truthy }
        end
        context "for genus Panax" do
          specify { @genus.cites_listed.should == false }
        end
      end

      describe :eu_listed do
        context "for species Panax ginseng" do
          specify { @species.eu_listed.should be_truthy }
        end
        context "for genus Panax" do
          specify { @genus.eu_listed.should == false }
        end
      end

      describe :cites_listing do
        context "for species Panax ginseng" do
          specify { @species.cites_listing.should == 'II/NC' }
        end
      end

      describe :eu_listing do
        context "for species Panax ginseng" do
          specify { @species.eu_listing.should == 'B/NC' }
        end
      end

      describe :ann_symbol do
        context "for species Panax ginseng" do
          specify { @species.ann_symbol.should_not be_blank }
        end
      end

      describe :hash_ann_symbol do
        context "for species Panax ginseng" do
          specify { @species.hash_ann_symbol.should == '#3' }
        end
      end
    end
  end
end
