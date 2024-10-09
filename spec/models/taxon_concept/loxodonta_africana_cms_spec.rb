require 'spec_helper'

describe TaxonConcept do
  context 'Loxodonta africana CMS' do
    include_context 'Loxodonta africana CMS'
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
          specify { expect(@species.family_name).to eq('Elephantidae') }
        end
        context 'order' do
          specify { expect(@species.order_name).to eq('Proboscidea') }
        end
        context 'class' do
          specify { expect(@species.class_name).to eq('Mammalia') }
        end
      end
    end

    context 'LISTING' do
      describe :cms_listing do
        context 'for species Loxodonta africana' do
          specify { expect(@species.cms_listing).to eq('II') }
        end
      end

      describe :cms_listed do
        context 'for species Loxodonta africana' do
          specify { expect(@species.cms_listed).to be_truthy }
        end
      end
    end
  end
end
