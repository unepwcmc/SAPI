require 'spec_helper'

describe TaxonConcept do
  context "Panax ginseng" do
    include_context "Panax ginseng"

    context "LISTING" do

      describe :cites_listed do
        context "for species Panax ginseng" do
          specify { expect(@species.cites_listed).to be_truthy }
        end
        context "for genus Panax" do
          specify { expect(@genus.cites_listed).to eq(false) }
        end
      end

      describe :eu_listed do
        context "for species Panax ginseng" do
          specify { expect(@species.eu_listed).to be_truthy }
        end
        context "for genus Panax" do
          specify { expect(@genus.eu_listed).to eq(false) }
        end
      end

      describe :cites_listing do
        context "for species Panax ginseng" do
          specify { expect(@species.cites_listing).to eq('II/NC') }
        end
      end

      describe :eu_listing do
        context "for species Panax ginseng" do
          specify { expect(@species.eu_listing).to eq('B/NC') }
        end
      end

      describe :ann_symbol do
        context "for species Panax ginseng" do
          specify { expect(@species.ann_symbol).not_to be_blank }
        end
      end

      describe :hash_ann_symbol do
        context "for species Panax ginseng" do
          specify { expect(@species.hash_ann_symbol).to eq('#3') }
        end
      end
    end
  end
end
