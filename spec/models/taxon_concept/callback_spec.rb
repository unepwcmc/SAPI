require 'spec_helper'

describe TaxonConcept do
  context 'before validate' do
    let(:kingdom_tc) do
      create_cites_eu_kingdom(
        taxonomic_position: '1'
      )
    end

    context 'taxonomic position not given for fixed order rank' do
      let(:tc) do
        create_cites_eu_phylum(
          parent_id: kingdom_tc.id,
          taxonomic_position: nil
        )
      end
      specify { expect(tc.taxonomic_position).to eq('1.1') }
    end
    context 'taxonomic position given for fixed order rank' do
      let(:tc) do
        create_cites_eu_phylum(
          parent_id: kingdom_tc.id,
          taxonomic_position: '1.2'
        )
      end
      specify { expect(tc.taxonomic_position).to eq('1.2') }
    end
    context 'taxonomic position not given for fixed order root rank' do
      let(:tc) do
        create_cites_eu_kingdom(
          taxonomic_position: nil
        )
      end
      specify { expect(tc.taxonomic_position).to eq('1') }
    end
  end

  context 'after save' do
    let(:genus_tc) do
      create_cites_eu_genus(
        parent: create_cites_eu_family(
          taxon_name: create(:taxon_name, scientific_name: 'Derp')
        )
      )
    end
    context 'data should be populated when creating a child' do
      let(:tc) do
        create_cites_eu_species(
          parent_id: genus_tc.id
        )
      end
      specify { expect(tc.data['family_name']).to eq('Derp') }
      specify { expect(tc.data['rank_name']).to eq(Rank::SPECIES) }
    end
  end
end
