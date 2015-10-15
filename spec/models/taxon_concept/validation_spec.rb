require 'spec_helper'

describe TaxonConcept do
  context "create" do
    let(:kingdom_tc){
      create_kingdom(
        :taxonomy_id => cites_eu.id,
        :taxonomic_position => '1',
        :taxon_name => build(:taxon_name, :scientific_name => 'Foobaria')
      )
    }
    context "all fine" do
      let(:tc){
        create_phylum(
          :taxonomy_id => cites_eu.id,
          :parent_id => kingdom_tc.id
        )
      }
      specify{ tc.valid? should be_true}
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
    context "parent name is incompatible" do
      let(:genus_tc){
        create_genus(
          :taxonomy_id => cites_eu.id,
          :taxon_name => build(:taxon_name, :scientific_name => 'Foobarus')
        )
      }
      let(:another_genus_tc){
        create_genus(
          :taxonomy_id => cites_eu.id,
          :taxon_name => build(:taxon_name, :scientific_name => 'Foobaria')
        )
      }
      let(:tc) {
        create_species(
          :taxonomy_id => cites_eu.id,
          :parent_id => genus_tc.id
        )
      }
      let(:tc_with_incompatible_parent){
        tc.parent = another_genus_tc
        tc
      }
      specify { tc_with_incompatible_parent.should have(1).error_on(:parent_id) }
    end
    context "parent is not an accepted name" do
      let(:genus_tc){
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
      let(:tc){
        build_phylum(
          :taxonomy_id => cites_eu.id,
          :parent_id => kingdom_tc.id,
          :taxonomic_position => '1.a.b'
        )
      }
      specify { tc.should have(1).error_on(:taxonomic_position) }
    end
    context "when full name is already given" do
      let!(:tc1) {
        create_cites_eu_subspecies(
          taxon_name: create(:taxon_name, scientific_name: 'duplicatus'),
        )
      }
      let!(:tc2) {
        build_cites_eu_subspecies(
          taxon_name: build(:taxon_name, scientific_name: 'duplicatus'),
        )
      }
      specify { tc2.should have(1).error_on(:full_name) }
    end
  end
  context "update" do
    let(:tc){ create_cites_eu_species }
    let!(:tc_child) { create_cites_eu_subspecies(parent_id: tc.id) }
    specify { tc.taxonomy = cms; tc.should have(1).error_on(:taxonomy_id) }
  end
end