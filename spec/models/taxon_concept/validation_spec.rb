require 'spec_helper'

describe TaxonConcept do
  context "create" do
    let(:kingdom_tc) {
      create_kingdom(
        :taxonomy_id => cites_eu.id,
        :taxonomic_position => '1',
        :taxon_name => build(:taxon_name, :scientific_name => 'Foobaria')
      )
    }
    context "all fine" do
      let(:tc) {
        create_phylum(
          :taxonomy_id => cites_eu.id,
          :parent_id => kingdom_tc.id
        )
      }
      specify { tc.valid? should be_truthy }
    end
    context "taxonomy does not match parent" do
      let(:tc) {
        build_phylum(
          :taxonomy_id => cms.id,
          :parent_id => kingdom_tc.id
        )
      }
      specify { tc.should have(1).error_on(:parent_id) }
    end
    context "parent is not an accepted name" do
      let(:genus_tc) {
        create_genus(
          :taxonomy_id => cites_eu.id,
          :name_status => 'S'
        )
      }
      let(:tc) {
        build_species(
          :taxonomy_id => cites_eu.id,
          :parent_id => genus_tc.id
        )
      }
      specify { tc.should have(1).error_on(:parent_id) }
    end
    context "parent rank is too high above child rank" do
      let(:tc) {
        build_class(
          :taxonomy_id => cites_eu.id,
          :parent_id => kingdom_tc.id
        )
      }
      specify { tc.should have(1).error_on(:parent_id) }
    end
    context "parent rank is below child rank" do
      let(:parent) {
        create_phylum(
          :taxonomy_id => cites_eu.id,
          :parent_id => kingdom_tc.id
        )
      }
      let(:tc) {
        build_kingdom(
          :taxonomy_id => cites_eu.id,
          :parent_id => parent.id
        )
      }
      specify { tc.should have(1).error_on(:parent_id) }
    end
    context "scientific name is not given" do
      let(:tc) {
        build_phylum(
          :taxonomy_id => cites_eu.id,
          :parent_id => kingdom_tc.id,
          :taxon_name => build(:taxon_name, :scientific_name => nil)
        )
      }
      specify { tc.should have(1).error_on(:taxon_name_id) }
    end
    context "when taxonomic position malformed" do
      let(:tc) {
        build_phylum(
          :taxonomy_id => cites_eu.id,
          :parent_id => kingdom_tc.id,
          :taxonomic_position => '1.a.b'
        )
      }
      specify { tc.should have(1).error_on(:taxonomic_position) }
    end
    context "when full name is already given" do
      let(:tc_parent) { create_cites_eu_species }
      let!(:tc1) {
        create_cites_eu_subspecies(
          parent: tc_parent,
          taxon_name: create(:taxon_name, scientific_name: 'duplicatus')
        )
      }
      let(:tc2) {
        build_cites_eu_subspecies(
          parent: tc_parent,
          taxon_name: build(:taxon_name, scientific_name: 'duplicatus')
        )
      }
      specify { tc2.should have(1).error_on(:full_name) }
    end
  end
  context "update" do
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
    context "taxonomy" do
      let!(:species_child) { create_cites_eu_subspecies(parent_id: species.id) }
      specify "cannot change taxonomy when dependents present" do
        species.taxonomy = cms
        expect(species).to have(1).error_on(:taxonomy_id)
      end
    end
    context "scientific name" do
      specify "cannot change species scientific name" do
        species.scientific_name = 'Vulgaris'
        expect(species).to have(1).error_on(:full_name)
      end
      specify "cannot change genus scientific name" do
        genus.scientific_name = 'Felis'
        expect(genus).to have(1).error_on(:full_name)
      end
    end
    context "parent" do
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
      specify "cannot change A species parent" do
        species.parent = new_genus
        expect(species).to have(1).error_on(:full_name)
      end
      specify "can change S species parent" do
        s_species.parent = new_genus
        expect(s_species).to have(0).error_on(:full_name)
      end
      specify "can change A genus parent" do
        genus.parent = new_family
        expect(genus).to have(0).error_on(:full_name)
      end
    end
    context "rank" do
      specify "cannot change A species rank" do
        species.rank = create(:rank, name: 'GENUS')
        expect(species).to have(1).error_on(:full_name)
      end
      specify "can change S species rank" do
        s_species.rank = create(:rank, name: 'GENUS')
        expect(s_species).to have(0).error_on(:full_name)
      end
    end
  end
end
