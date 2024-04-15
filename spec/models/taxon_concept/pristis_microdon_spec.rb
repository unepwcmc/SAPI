require 'spec_helper'

describe TaxonConcept do
  context "Pristis microdon" do
    include_context "Pristis microdon"

    context "LISTING" do
      describe :cites_listing do
        context 'for family Pristidae' do
          specify { expect(@family.cites_listing).to eq('I') }
        end
        context 'for species Pristis microdon' do
          specify { expect(@species.cites_listing).to eq('I') }
        end
      end

      describe :cites_listed do
        context "for species Pristis microdon" do
          specify { expect(@species.cites_listed).to eq(false) }
        end
      end

      describe :cites_show do
        context "for species Pristis microdon" do
          specify { expect(@species.cites_show).to be_truthy }
        end
      end

      describe :eu_listing do
        context 'for family Pristidae' do
          specify { expect(@family.eu_listing).to eq('A') }
        end
        context 'for species Pristis microdon' do
          specify { expect(@species.eu_listing).to eq('A') }
        end
      end

      describe :eu_listed do
        context "for species Pristis microdon" do
          specify { expect(@species.eu_listed).to eq(false) }
        end
      end

      describe :eu_show do
        context "for species Pristis microdon" do
          specify { expect(@species.eu_show).to be_truthy }
        end
      end

    end
  end
end
