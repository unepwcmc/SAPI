require 'spec_helper'

describe TaxonConcept do
  context 'Loxodonta africana' do
    include_context 'Loxodonta africana'
    context 'TAXONOMY' do
      describe :full_name do
        context 'for species Loxodonta africana' do
          specify { expect(@species.full_name).to eq('Loxodonta africana') }
        end
        context 'for genus Loxodonta' do
          specify { expect(@genus.full_name).to eq('Loxodonta') }
        end
      end
      describe :rank do
        context 'for species Loxodonta africana' do
          specify { expect(@species.rank_name).to eq('SPECIES') }
        end
      end
      describe :ancestors do
        context 'family' do
          specify { @species.family_name == 'Elephantidae' }
        end
        context 'order' do
          specify { @species.order_name == 'Proboscidea' }
        end
        context 'class' do
          specify { @species.class_name == 'Mammalia' }
        end
      end
    end

    context 'LISTING' do
      describe :cites_listing do
        context 'for species Loxodonta africana (population split listing)' do
          specify { expect(@species.cites_listing).to eq('I/II') }
        end
      end

      describe :eu_listing do
        context 'for species Loxodonta africana (population split listing)' do
          specify { expect(@species.eu_listing).to eq('A/B') }
        end
      end

      describe :cites_listed do
        context 'for species Loxodonta africana' do
          specify { expect(@species.cites_listed).to be_truthy }
        end
        context 'for family Elephantidae' do
          specify { expect(@family.cites_listed).to eq(false) }
        end
      end

      describe :eu_listed do
        context 'for species Loxodonta africana' do
          specify { expect(@species.eu_listed).to be_truthy }
        end
        context 'for family Elephantidae' do
          specify { expect(@family.eu_listed).to eq(false) }
        end
      end
    end
  end
end
