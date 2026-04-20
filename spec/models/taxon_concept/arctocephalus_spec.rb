require 'spec_helper'

describe TaxonConcept do
  context 'Arctocephalus' do
    include_context 'Arctocephalus'

    context 'LISTING' do
      describe :cites_listing do
        it 'is II at species level Arctocephalus australis' do
          expect(@species1.cites_listing).to eq('II')
        end

        it 'is I at species level Arctocephalus townsendi' do
          expect(@species2.cites_listing).to eq('I')
        end

        it 'is I/II at genus level Arctocephalus' do
          expect(@genus.cites_listing).to eq('I/II')
        end
      end

      describe :cites_listed do
        it 'is true for genus Arctocephalus' do
          expect(@genus.cites_listed).to be_truthy
        end

        it 'is true for species Arctocephalus townsendi' do
          expect(@species2.cites_listed).to be_truthy
        end

        it 'is false for species Arctocephalus australis (inclusion in higher taxa listing)' do
          expect(@species1.cites_listed).to eq(false)
        end
      end

      describe :eu_listed do
        it 'is true for genus Arctocephalus' do
          expect(@genus.eu_listed).to be_truthy
        end

        it 'is true for species Arctocephalus townsendi' do
          expect(@species2.eu_listed).to be_truthy
        end

        it 'is false for species Arctocephalus australis (inclusion in higher taxa listing)' do
          expect(@species1.eu_listed).to eq(false)
        end
      end
    end
  end
end
