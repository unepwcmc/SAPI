require 'spec_helper'

describe TaxonConcept do
  context 'create' do
    let(:kingdom_tc) do
      create_kingdom(
        taxonomy_id: cites_eu.id,
        taxonomic_position: '1',
        taxon_name: build(:taxon_name, scientific_name: 'Foobaria')
      )
    end
    context 'all fine' do
      let(:tc) do
        create_phylum(
          taxonomy_id: cites_eu.id,
          parent_id: kingdom_tc.id
        )
      end
      specify { tc.valid? is_expected.to be_truthy }
    end
    context 'taxonomy does not match parent' do
      let(:tc) do
        build_phylum(
          taxonomy_id: cms.id,
          parent_id: kingdom_tc.id
        )
      end
      specify { expect(tc.error_on(:parent_id).size).to eq(1) }
    end
    context 'parent is not an accepted name' do
      let(:genus_tc) do
        create_genus(
          taxonomy_id: cites_eu.id,
          name_status: 'S'
        )
      end
      let(:tc) do
        build_species(
          taxonomy_id: cites_eu.id,
          parent_id: genus_tc.id
        )
      end
      specify { expect(tc.error_on(:parent_id).size).to eq(1) }
    end
    context 'parent rank is too high above child rank' do
      let(:tc) do
        build_class(
          taxonomy_id: cites_eu.id,
          parent_id: kingdom_tc.id
        )
      end
      specify { expect(tc.error_on(:parent_id).size).to eq(1) }
    end
    context 'parent rank is below child rank' do
      let(:parent) do
        create_phylum(
          taxonomy_id: cites_eu.id,
          parent_id: kingdom_tc.id
        )
      end
      let(:tc) do
        build_kingdom(
          taxonomy_id: cites_eu.id,
          parent_id: parent.id
        )
      end
      specify { expect(tc.error_on(:parent_id).size).to eq(1) }
    end
    context 'scientific name is not given' do
      let(:tc) do
        build_phylum(
          taxonomy_id: cites_eu.id,
          parent_id: kingdom_tc.id,
          taxon_name: build(:taxon_name, scientific_name: nil)
        )
      end
      specify { expect(tc.error_on(:taxon_name_id).size).to eq(1) }
    end
    context 'when taxonomic position malformed' do
      let(:tc) do
        build_phylum(
          taxonomy_id: cites_eu.id,
          parent_id: kingdom_tc.id,
          taxonomic_position: '1.a.b'
        )
      end
      specify { expect(tc.error_on(:taxonomic_position).size).to eq(1) }
    end
    context 'when full name is already given' do
      let(:tc_parent) { create_cites_eu_species }
      let!(:tc1) do
        create_cites_eu_subspecies(
          parent: tc_parent,
          taxon_name: create(:taxon_name, scientific_name: 'duplicatus')
        )
      end
      let(:tc2) do
        build_cites_eu_subspecies(
          parent: tc_parent,
          taxon_name: build(:taxon_name, scientific_name: 'duplicatus')
        )
      end
      specify { expect(tc2.error_on(:full_name).size).to eq(1) }
    end
  end
  context 'update' do
    let(:family) do
      create_cites_eu_family(
        taxon_name: create(:taxon_name, scientific_name: 'Felidae')
      )
    end
    let(:genus) do
      create_cites_eu_genus(
        parent: family,
        taxon_name: create(:taxon_name, scientific_name: 'Lynx')
      )
    end
    let(:species) do
      create_cites_eu_species(
        parent: genus,
        taxon_name: create(:taxon_name, scientific_name: 'Domesticus')
      )
    end
    let(:s_species) do
      create_cites_eu_species(
        parent: genus,
        taxon_name: create(:taxon_name, scientific_name: 'Felis domesticus'),
        name_status: 'S'
      )
    end
    context 'taxonomy' do
      let!(:species_child) { create_cites_eu_subspecies(parent_id: species.id) }
      specify 'cannot change taxonomy when dependents present' do
        species.taxonomy = cms
        expect(species.error_on(:taxonomy_id).size).to eq(1)
      end
    end
    context 'scientific name' do
      specify 'cannot change species scientific name' do
        species.scientific_name = 'Vulgaris'
        expect(species.error_on(:full_name).size).to eq(1)
      end
      specify 'cannot change genus scientific name' do
        genus.scientific_name = 'Felis'
        expect(genus.error_on(:full_name).size).to eq(1)
      end
    end
    context 'parent' do
      let(:new_family) do
        create_cites_eu_family(
          taxon_name: create(:taxon_name, scientific_name: 'Canidae')
        )
      end
      let(:new_genus) do
        create_cites_eu_genus(
          parent: new_family,
          taxon_name: create(:taxon_name, scientific_name: 'Felis')
        )
      end
      specify 'cannot change A species parent' do
        species.parent = new_genus
        expect(species.error_on(:full_name).size).to eq(1)
      end
      specify 'can change S species parent' do
        s_species.parent = new_genus
        expect(s_species.error_on(:full_name).size).to eq(0)
      end
      specify 'can change A genus parent' do
        genus.parent = new_family
        expect(genus.error_on(:full_name).size).to eq(0)
      end
    end
    context 'rank' do
      specify 'cannot change A species rank' do
        species.rank = create(:rank, name: 'GENUS')
        expect(species.error_on(:full_name).size).to eq(1)
      end
      specify 'can change S species rank' do
        s_species.rank = create(:rank, name: 'GENUS')
        expect(s_species.error_on(:full_name).size).to eq(0)
      end
    end
    context 'author_year' do
      specify 'is valid with lots of non-ASCII PDF-safe characters' do
        species.author_year = 'Sigríður O’Brian–Żądło (2003)'
        expect(species.error_on(:author_year).size).to eq(0)
      end

      specify 'is not valid with cyrillic characters' do
        species.author_year = 'Дмитровна (2001)'
        expect(species.error_on(:author_year)).to contain_exactly(
          'should only contain PDF-safe characters'
        )
      end
    end
  end
end
