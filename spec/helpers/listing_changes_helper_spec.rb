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
describe ListingChangesHelper do
  let(:poland) do
    GeoEntity.find_by(iso_code2: 'PL') || create(:geo_entity, iso_code2: 'PL', name: 'Poland')
  end
  let(:taxon_concept) do
    create_cites_eu_genus(
      taxon_name: create(:taxon_name, scientific_name: 'Foobarus')
    )
  end
  let(:annotation) do
    create(
      :annotation,
      short_note_en: 'Only population of PL',
      full_note_en: 'Only population of Poland'
    )
  end
  let(:hash_annotation) do
    create(
      :annotation,
      symbol: '#1',
      parent_symbol: 'CoP1',
      full_note_en: 'Only seeds and roots.'
    )
  end
  let(:listing_change) do
    create_cites_I_addition(
      taxon_concept_id: taxon_concept.id,
      annotation_id: annotation.id,
      hash_annotation_id: hash_annotation.id
    )
  end

  describe 'geo_entities_tooltip' do
    let!(:listing_distribution) do
      create(
        :listing_distribution,
        listing_change_id: listing_change.id,
        geo_entity_id: poland.id,
        is_party: false
      )
    end
    it 'outputs all geo entities comma separated' do
      expect(helper.geo_entities_tooltip(listing_change)).to eq('Poland')
    end
  end
  describe 'annotation_tooltip' do
    it 'outputs the regular annotation in both short and long English form' do
      expect(helper.annotation_tooltip(listing_change)).to eq(
        'Only population of PL (Only population of Poland)'
      )
    end
  end
  describe 'hash_annotation_tooltip' do
    it 'outputs the hash annotation in long English form' do
      expect(helper.hash_annotation_tooltip(listing_change)).to eq(
        'Only seeds and roots.'
      )
    end
  end
  describe 'excluded_geo_entities_tooltip' do
    context 'no exclusions' do
      it 'should output blank exception' do
        expect(helper.excluded_geo_entities_tooltip(listing_change)).to be_blank
      end
    end

    context 'geographic exclusion' do
      let(:exclusion) do
        create_cites_I_exception(
          parent_id: listing_change.id,
          taxon_concept_id: listing_change.taxon_concept_id
        )
      end
      let!(:listing_distribution) do
        create(
          :listing_distribution,
          listing_change_id: exclusion.id,
          geo_entity_id: poland.id,
          is_party: false
        )
      end
      it 'should list geographic exception' do
        expect(helper.excluded_geo_entities_tooltip(listing_change)).to eq('Poland')
      end
    end
  end
  describe 'excluded_taxon_concepts_tooltip' do
    let(:child_taxon_concept) do
      create_cites_eu_species(
        parent_id: taxon_concept.id,
        taxon_name: create(:taxon_name, scientific_name: 'cracovianus')
      )
    end
    context 'no exclusions' do
      it 'should output blank exception' do
        expect(helper.excluded_taxon_concepts_tooltip(listing_change)).to be_blank
      end
    end

    context 'taxonomic exclusion' do
      let!(:exclusion) do
        create_cites_I_exception(
          taxon_concept_id: child_taxon_concept.id,
          parent_id: listing_change.id
        )
      end
      it 'should list taxonomic exception' do
        expect(helper.excluded_taxon_concepts_tooltip(listing_change)).to eq('Foobarus cracovianus')
      end
    end
  end
end
