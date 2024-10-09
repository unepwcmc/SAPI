require 'spec_helper'

describe TaxonConcept do
  context 'Notomys aquilo' do
    include_context 'Notomys aquilo'

    context 'LISTING' do
      describe :cites_listing do
        context 'for genus Notomys' do
          specify { expect(@genus.cites_listing).to eq('NC') }
        end
        context 'for species Notomys aquilo' do
          specify { expect(@species.cites_listing).to eq('NC') }
        end
      end

      describe :cites_show do
        context 'for genus Notomys' do
          specify { expect(@genus.cites_show).to be_falsey }
        end
        context 'for species Notomys aquilo' do
          specify { expect(@species.cites_show).to be_falsey }
        end
      end
    end
  end
end
