require 'spec_helper'

describe TaxonConcept do
  context 'Caiman latirostris' do
    include_context 'Caiman latirostris'

    context 'TAXONOMY' do
      describe :full_name do
        context 'for species synonym Alligator cynocephalus' do
          specify { expect(@species1.full_name).to eq('Alligator cynocephalus') }
        end
      end
      describe :rank_name do
        context 'for species synonym Alligator cynocephalus' do
          specify { expect(@species1.rank_name).to eq(Rank::SPECIES) }
        end
      end
    end

    context 'REFERENCES' do
      describe :cites_accepted do
        context 'for species Caiman latirostris' do
          specify { expect(@species.cites_accepted).to be_truthy }
        end
        context 'for synonym species Alligator cynocephalus' do
          specify { expect(@species1.cites_accepted).to eq(false) }
        end
      end
      describe :standard_taxon_concept_references do
        context 'for species Caiman latirostris' do
          specify { expect(@species.taxon_concept.standard_taxon_concept_references.map(&:reference_id)).to include @ref.id }
        end
      end
    end
    context 'LISTING' do
      describe :cites_listing do
        context 'for species Caiman latirostris' do
          specify { expect(@species.cites_listing).to eq('I/II') }
        end
      end

      describe :eu_listing do
        context 'for species Caiman latirostris' do
          specify { expect(@species.eu_listing).to eq('A/B') }
        end
      end

      describe :cites_listed do
        context 'for order Crocodylia' do
          specify { expect(@order.cites_listed).to be_truthy }
        end
        context 'for family Alligatoridae' do
          specify { expect(@family.cites_listed).to eq(false) }
        end
        context 'for genus Caiman' do
          specify { expect(@genus.cites_listed).to eq(false) }
        end
        context 'for species Caiman latoristris' do
          specify { expect(@species.cites_listed).to be_truthy }
        end
      end

      describe :eu_listed do
        context 'for order Crocodylia' do
          specify { expect(@order.eu_listed).to be_truthy }
        end
        context 'for family Alligatoridae' do
          specify { expect(@family.eu_listed).to eq(false) }
        end
        context 'for genus Caiman' do
          specify { expect(@genus.eu_listed).to eq(false) }
        end
        context 'for species Caiman latoristris' do
          specify { expect(@species.eu_listed).to be_truthy }
        end
      end

      describe :cites_show do
        context 'for order Crocodylia' do
          specify { expect(@order.cites_show).to be_truthy }
        end
        context 'for family Alligatoridae' do
          specify { expect(@family.cites_show).to be_truthy }
        end
        context 'for genus Caiman' do
          specify { expect(@genus.cites_show).to be_truthy }
        end
        context 'for species Caiman latoristris' do
          specify { expect(@species.cites_show).to be_truthy }
        end
        context 'for synonym species Alligator cynocephalus' do
          specify { expect(@species1.cites_show).to be_falsey }
        end
      end

      describe :ann_symbol do
        context 'for species Caiman latirostris' do
          specify { expect(@species.ann_symbol).not_to be_blank }
        end
      end

      describe :hash_ann_symbol do
        context 'for species Caiman latirostris' do
          specify { expect(@species.hash_ann_symbol).to be_blank }
        end
      end
    end
  end
end
