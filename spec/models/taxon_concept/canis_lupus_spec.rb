require 'spec_helper'

describe TaxonConcept do
  context 'Canis lupus' do
    include_context 'Canis lupus'
    context 'LISTING' do
      describe :cites_listing do
        context 'for species Canis lupus (population split listing)' do
          specify { expect(@species.cites_listing).to eq('I/II') }
        end
      end

      describe :eu_listing do
        context 'for species Canis lupus (population split listing)' do
          specify { expect(@species.eu_listing).to eq('A/B') }
        end
      end

      describe :cites_listed do
        context 'for species Canis lupus' do
          specify { expect(@species.cites_listed).to be_truthy }
        end
        context 'for subspecies Canis lupus crassodon' do
          specify { expect(@subspecies.cites_listed).to be_blank }
        end
      end

      describe :eu_listed do
        context 'for species Canis lupus' do
          specify { expect(@species.eu_listed).to be_truthy }
        end
      end

      describe :show_in_species_plus_ac do
        context 'for species Canis lupus' do
          specify { expect(@species_ac.show_in_species_plus_ac).to be_truthy }
        end
        context 'for subspecies Canis lupus crassodon' do
          specify { expect(@subspecies_ac.show_in_species_plus_ac).to be_truthy }
        end
      end

      describe :show_in_checklist_ac do
        context 'for species Canis lupus' do
          specify { expect(@species_ac.show_in_checklist_ac).to be_truthy }
        end
        context 'for subspecies Canis lupus crassodon' do
          specify { expect(@subspecies_ac.show_in_checklist_ac).to be_falsey }
        end
      end

      describe :show_in_species_plus do
        context 'for species Canis lupus' do
          specify { expect(@species.show_in_species_plus).to be_truthy }
        end
        context 'for subspecies Canis lupus crassodon' do
          specify { expect(@subspecies.show_in_species_plus).to be_truthy }
        end
      end
    end
  end
end
