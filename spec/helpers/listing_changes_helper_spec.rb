require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the ListingChangesHelper. For example:
#
# describe ListingChangesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe ListingChangesHelper, type: :helper do
  let(:poland) {
    GeoEntity.find_by_iso_code2('PL') || create(:geo_entity, :iso_code2 => 'PL', :name => 'Poland')
  }
  let(:taxon_concept) {
    create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Foobarus')
    )
  }
  let(:annotation) {
    create(
      :annotation,
      :short_note_en => 'Only population of PL',
      :full_note_en => 'Only population of Poland'
    )
  }
  let(:hash_annotation) {
    create(
      :annotation,
      :symbol => '#1',
      :parent_symbol => 'CoP1',
      :full_note_en => 'Only seeds and roots.'
    )
  }
  let(:listing_change) {
    create_cites_I_addition(
      :taxon_concept_id => taxon_concept.id,
      :annotation_id => annotation.id,
      :hash_annotation_id => hash_annotation.id
    )
  }

  describe 'geo_entities_tooltip' do
    let!(:listing_distribution) {
      create(
        :listing_distribution,
        :listing_change_id => listing_change.id,
        :geo_entity_id => poland.id,
        :is_party => false
      )
    }
    it "outputs all geo entities comma separated" do
      helper.geo_entities_tooltip(listing_change).should == 'Poland'
    end
  end
  describe 'annotation_tooltip' do
    it "outputs the regular annotation in both short and long English form" do
      helper.annotation_tooltip(listing_change).should ==
        "Only population of PL (Only population of Poland)"
    end
  end
  describe 'hash_annotation_tooltip' do
    it "outputs the hash annotation in long English form" do
      helper.hash_annotation_tooltip(listing_change).should ==
        "Only seeds and roots."
    end
  end
  describe 'excluded_geo_entities_tooltip' do
    context "no exclusions" do
      it "should output blank exception" do
        helper.excluded_geo_entities_tooltip(listing_change).should be_blank
      end
    end

    context "geographic exclusion" do
      let(:exclusion) {
        create_cites_I_exception(
          :parent_id => listing_change.id,
          :taxon_concept_id => listing_change.taxon_concept_id
        )
      }
      let!(:listing_distribution) {
        create(
          :listing_distribution,
          :listing_change_id => exclusion.id,
          :geo_entity_id => poland.id,
          :is_party => false
        )
      }
      it "should list geographic exception" do
        helper.excluded_geo_entities_tooltip(listing_change).should == 'Poland'
      end
    end
  end
  describe 'excluded_taxon_concepts_tooltip' do
    let(:child_taxon_concept) {
      create_cites_eu_species(
        :parent_id => taxon_concept.id,
        :taxon_name => create(:taxon_name, :scientific_name => 'cracovianus')
      )
    }
    context "no exclusions" do
      it "should output blank exception" do
        helper.excluded_taxon_concepts_tooltip(listing_change).should be_blank
      end
    end

    context "taxonomic exclusion" do
      let!(:exclusion) {
        create_cites_I_exception(
          :taxon_concept_id => child_taxon_concept.id,
          :parent_id => listing_change.id
        )
      }
      it "should list taxonomic exception" do
        helper.excluded_taxon_concepts_tooltip(listing_change).should == 'Foobarus cracovianus'
      end
    end

  end

end
