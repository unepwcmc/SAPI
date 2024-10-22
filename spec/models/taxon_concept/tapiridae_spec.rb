require 'spec_helper'

describe TaxonConcept do
  context 'Tapiridae' do
    include_context 'Tapiridae'
    context 'TAXONOMY' do
      describe :full_name do
        context 'for family Tapiridae' do
          specify { expect(@family.full_name).to eq('Tapiridae') }
        end
      end
      describe :rank do
        context 'for family Tapiridae' do
          specify { expect(@family.rank_name).to eq('FAMILY') }
        end
      end
      describe :ancestors do
        context 'order' do
          specify { @species.order_name == 'Perissodactyla' }
        end
        context 'class' do
          specify { @species.class_name == 'Mammalia' }
        end
      end
    end

    context 'LISTING' do
      describe :cites_listing do
        context 'for family Tapiridae' do
          specify { expect(@family.cites_listing).to eq('I/II') }
        end
        context 'for species Tapirus terrestris' do
          specify { expect(@species.cites_listing).to eq('II') }
        end
      end

      describe :eu_listing do
        context 'for family Tapiridae' do
          specify { expect(@family.eu_listing).to eq('A/B') }
        end
        context 'for species Tapirus terrestris' do
          specify { expect(@species.eu_listing).to eq('B') }
        end
      end

      describe :cites_listed do
        context 'for family Tapiridae' do
          specify { expect(@family.cites_listed).to be_truthy }
        end
        context 'for genus Tapirus' do
          specify { expect(@genus.cites_listed).to eq(false) }
        end
        context 'for species Tapirus terrestris' do
          specify { expect(@species.cites_listed).to be_truthy }
        end
      end

      describe :eu_listed do
        context 'for family Tapiridae' do
          specify { expect(@family.eu_listed).to be_truthy }
        end
        context 'for genus Tapirus' do
          specify { expect(@genus.eu_listed).to eq(false) }
        end
        context 'for species Tapirus terrestris' do
          specify { expect(@species.eu_listed).to be_truthy }
        end
      end
    end
  end
end
