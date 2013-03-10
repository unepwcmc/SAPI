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
  end
end