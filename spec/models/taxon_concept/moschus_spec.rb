require 'spec_helper'

describe TaxonConcept do
  context 'Moschus' do
    include_context 'Moschus'

    context 'LISTING' do
      describe :cites_listing do
        context 'for genus Moschus' do
          specify { expect(@genus.cites_listing).to eq('I/II') }
        end
        context 'for species Moschus leucogaster' do
          specify { expect(@species1.cites_listing).to eq('I') }
        end
        context 'for species Moschus moschiferus' do
          specify { expect(@species2.cites_listing).to eq('II') }
        end
        context 'for subspecies Moschus moschiferus moschiferus' do
          specify { expect(@subspecies.cites_listing).to eq('II') }
        end
      end

      describe :cites_listed do
        context 'for genus Moschus' do
          specify { expect(@genus.cites_listed).to be_truthy }
        end
        context 'for species Moschus leucogaster' do
          specify { expect(@species1.cites_listed).to eq(false) }
        end
        context 'for species Moschus moschiferus' do
          specify { expect(@species2.cites_listed).to eq(false) }
        end
        context 'for subspecies Moschus moschiferus moschiferus' do
          specify { expect(@subspecies.cites_listed).to eq(false) }
        end
      end
    end

    context 'CASCADING LISTING' do
      describe :current_cites_additions do
        context 'for species Moschus leucogaster' do
          specify do
            expect(@species1.current_cites_additions.size).to eq(1)
            addition = @species1.current_cites_additions.first
            expect(addition.original_taxon_concept_id).to eq(@genus.id)
            # should inherit just the I listing from split listed genus
            expect(addition.species_listing_name).to eq('I')
          end
        end
        context 'for species Moschus moschiferus' do
          specify do
            expect(@species2.current_cites_additions.size).to eq(1)
            addition = @species2.current_cites_additions.first
            expect(addition.original_taxon_concept_id).to eq(@genus.id)
            # should inherit just the II listing from split listed genus
            expect(addition.species_listing_name).to eq('II')
          end
        end
        context 'for subspecies Moschus moschiferus moschiferus' do
          specify do
            expect(@subspecies.current_cites_additions.size).to eq(1)
            addition = @subspecies.current_cites_additions.first
            expect(addition.original_taxon_concept_id).to eq(@genus.id)
            # should inherit just the II listing from split listed genus
            expect(addition.species_listing_name).to eq('II')
          end
        end
      end
    end
  end
end
