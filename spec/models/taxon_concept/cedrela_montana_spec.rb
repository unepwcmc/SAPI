require 'spec_helper'

describe TaxonConcept do
  context "Cedrela montana" do
    include_context "Cedrela montana"

    context "LISTING" do
      describe :cites_listing do
        context 'for species Cedrela montana' do
          specify { expect(@species.cites_listing).to be_blank }
        end
      end

      describe :cites_listed do
        context "for species Cedrela montana" do
          specify { expect(@species.cites_listed).to be_nil }
        end
      end

      describe :cites_show do
        context "for species Cedrela montana" do
          specify { expect(@species.cites_show).to be_falsey }
        end
      end

      describe :eu_listing do
        context 'for species Cedrela montana' do
          specify { expect(@species.eu_listing).to eq('D') }
        end
      end

      describe :eu_listed do
        context "for species Cedrela montana" do
          specify { expect(@species.eu_listed).to be_truthy }
        end
      end

      describe :eu_show do
        context "for species Cedrela montana" do
          specify { expect(@species.eu_show).to be_truthy }
        end
      end

    end
  end
end
