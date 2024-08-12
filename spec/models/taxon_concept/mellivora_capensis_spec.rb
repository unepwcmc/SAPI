require 'spec_helper'

describe TaxonConcept do
  context 'Mellivora capensis' do
    include_context 'Mellivora capensis'
    context 'LISTING' do
      describe :cites_listing do
        context 'for species Mellivora capensis' do
          specify { expect(@species.cites_listing).to eq('III') }
        end
      end

      describe :eu_listing do
        context 'for species Mellivora capensis' do
          specify { expect(@species.eu_listing).to eq('C') }
        end
      end

      describe :cites_listed do
        context 'for family Mustelinae' do
          specify { expect(@family.cites_listed).to eq(false) }
        end
        context 'for genus Mellivora' do
          specify { expect(@genus.cites_listed).to eq(false) }
        end
        context 'for species Mellivora capensis' do
          specify { expect(@species.cites_listed).to be_truthy }
        end
      end

      describe :eu_listed do
        context 'for family Mustelinae' do
          specify { expect(@family.eu_listed).to eq(false) }
        end
        context 'for genus Mellivora' do
          specify { expect(@genus.eu_listed).to eq(false) }
        end
        context 'for species Mellivora capensis' do
          specify { expect(@species.eu_listed).to be_truthy }
        end
      end

      describe :current_party_ids do
        context 'for species Mellivora capensis' do
          specify { expect(@species.current_parties_ids).to eq([ GeoEntity.find_by_iso_code2('BW').id ]) }
        end
      end
    end
  end
end
