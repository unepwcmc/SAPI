require 'spec_helper'

describe TaxonConcept do
  context 'Diospyros' do
    include_context 'Diospyros'

    context 'LISTING' do
      describe :cites_listing do
        context 'for species Diospyros aculeata' do
          specify { expect(@species1.cites_listing).to eq('II') }
        end
        context 'for species Diospyros acuta' do
          specify { expect(@species2.cites_listing).to eq('NC') }
        end
      end

      describe :cites_listed do
        context 'for species Diospyros aculeata' do
          specify { expect(@species1.cites_listed).to eq(false) }
        end
        context 'for species Diospyros acuta' do
          specify { expect(@species2.cites_listed).to be_nil }
        end
      end

      describe :cites_show do
        context 'for species Diospyros aculeata' do
          specify { expect(@species1.cites_show).to be_truthy }
        end
        context 'for species Diospyros acuta' do
          specify { expect(@species2.cites_show).to be_falsey }
        end
      end

      describe :eu_listing do
        context 'for species Diospyros aculeata' do
          specify { expect(@species1.eu_listing).to eq('B') }
        end
        context 'for species Diospyros acuta' do
          specify { expect(@species2.eu_listing).to eq('NC') }
        end
      end

      describe :eu_listed do
        context 'for species Diospyros aculeata' do
          specify { expect(@species1.eu_listed).to eq(false) }
        end
        context 'for species Diospyros acuta' do
          specify { expect(@species2.eu_listed).to be_nil }
        end
      end

      describe :eu_show do
        context 'for species Diospyros aculeata' do
          specify { expect(@species1.eu_show).to be_truthy }
        end
        context 'for species Diospyros acuta' do
          specify { expect(@species2.eu_show).to be_falsey }
        end
      end
    end
  end
end
