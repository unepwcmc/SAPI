require 'spec_helper'

describe TaxonConcept do
  context 'Pseudomys fieldi' do
    include_context 'Pseudomys fieldi'

    context 'LISTING' do
      describe :cites_listing do
        context 'for subspecies Pseudomys fieldi preaconis' do
          specify { expect(@subspecies.cites_listing).to eq('I') }
        end
        context 'for species Pseudomys fieldi' do
          specify { expect(@species.cites_listing).to eq('I/NC') }
        end
      end

      describe :eu_listing do
        context 'for subspecies Pseudomys fieldi preaconis' do
          specify { expect(@subspecies.eu_listing).to eq('A') }
        end
        context 'for species Pseudomys fieldi' do
          specify { expect(@species.eu_listing).to eq('A/NC') }
        end
      end

      describe :cites_show do
        context 'for subspecies Pseudomys fieldi preaconis' do
          specify { expect(@subspecies.cites_show).to be_truthy }
        end
        context 'for species Pseudomys fieldi' do
          specify { expect(@species.cites_show).to be_truthy }
        end
      end

      # describe :eu_show do
      #   context "for subspecies Pseudomys fieldi preaconis" do
      #     specify{ @subspecies.eu_show.should be_truthy }
      #   end
      #   context "for species Pseudomys fieldi" do
      #     specify{ @species.eu_show.should be_truthy }
      #   end
      # end
    end
  end
end
