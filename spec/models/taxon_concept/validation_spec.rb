require 'spec_helper'

describe TaxonConcept do
  include_context :designations
  include_context :ranks
  context "create" do
    
    let(:kingdom){ Rank.find_by_name('KINGDOM') }
    let(:phylum){ Rank.find_by_name('PHYLUM') }
    let(:klass){ Rank.find_by_name('CLASS') }
    let(:kingdom_tc){
      create(
        :taxon_concept,
        :taxonomy_id => cites_eu.id,
        :rank_id => kingdom.id,
        :taxonomic_position => '1',
        :taxon_name => build(:taxon_name, :scientific_name => 'Foobaria')
      )
    }
    context "all fine" do
      let(:tc){
        create(
          :taxon_concept,
          :taxonomy_id => cites_eu.id,
          :rank_id => phylum.id,
          :parent_id => kingdom_tc.id
        )
      }
      specify{ tc.valid? should be_true}
    end
    context "taxonomy does not match parent" do
      let(:tc) {
        build(
          :taxon_concept,
          :taxonomy_id => cms.id,
          :rank_id => phylum.id,
          :parent_id => kingdom_tc.id
        )
      }
      specify { tc.should have(1).error_on(:parent_id) }
    end
    
    context "parent rank is too high above child rank" do
      let(:tc) {
        build(
          :taxon_concept,
          :taxonomy_id => cites_eu.id,
          :parent_id => kingdom_tc.id,
          :rank_id => klass.id
        )
      }
      specify { tc.should have(1).error_on(:parent_id) }
    end
    context "parent rank is below child rank" do
      let(:parent) {
        create(
          :taxon_concept,
          :taxonomy_id => cites_eu.id,
          :parent_id => kingdom_tc.id,
          :rank_id => phylum.id
        )
      }
      let(:tc) {
        build(
          :taxon_concept,
          :taxonomy_id => cites_eu.id,
          :parent_id => parent.id,
          :rank_id => kingdom.id
        )
      }
      specify { tc.should have(1).error_on(:parent_id) }
    end
    context "scientific name is not given" do
      let(:tc) {
        build(
          :taxon_concept,
          :taxonomy_id => cites_eu.id,
          :parent_id => kingdom_tc.id,
          :rank_id => phylum.id,
          :taxon_name => build(:taxon_name, :scientific_name => nil)
        )
      }
      specify { tc.should have(1).error_on(:taxon_name_id) }
    end
  end
end