require 'spec_helper'

describe ListingChange do
  context 'validations' do
    describe :create do
      context 'all fine with exception' do
        let!(:exception_type) { cites_exception }
        let(:taxon_concept) { create_cites_eu_species }
        let(:excluded_taxon_concept) { create_cites_eu_subspecies(parent: taxon_concept) }
        let(:listing_change) do
          build(
            :listing_change,
            change_type: cites_addition,
            species_listing: cites_I,
            taxon_concept: taxon_concept,
            excluded_taxon_concepts_ids: "#{excluded_taxon_concept.id}"
          )
        end
        specify { expect(listing_change).to be_valid }
      end
      context 'inclusion taxon concept is lower rank' do
        let(:inclusion) { create_cites_eu_subspecies }
        let(:taxon_concept) { create_cites_eu_species }
        let(:listing_change) do
          build(
            :listing_change,
            taxon_concept: taxon_concept,
            inclusion_taxon_concept_id: inclusion.id
          )
        end
        specify { expect(listing_change.error_on(:inclusion_taxon_concept_id).size).to eq(1) }
      end
      context 'species listing designation mismatch' do
        let(:designation1) { create(:designation) }
        let(:designation2) { create(:designation) }
        let(:listing_change) do
          build(
            :listing_change,
            species_listing: create(:species_listing, designation: designation1),
            change_type: create(:change_type, designation: designation2)
          )
        end
        specify { expect(listing_change.error_on(:species_listing_id).size).to eq(1) }
      end
      context 'event designation mismatch' do
        let(:designation1) { create(:designation) }
        let(:designation2) { create(:designation) }
        let(:listing_change) do
          build(
            :listing_change,
            event_id: create(:event, designation: designation1).id,
            change_type: create(:change_type, designation: designation2)
          )
        end
        specify { expect(listing_change.error_on(:event_id).size).to eq(1) }
      end
    end
  end
  describe :effective_at_formatted do
    let(:listing_change) { create_cites_I_addition(effective_at: '2012-05-10') }
    specify { expect(listing_change.effective_at_formatted).to eq('10/05/2012') }
  end

  describe :duplicates do
    let(:lc1) do
      lc = create_cites_I_addition(effective_at: '2014-11-17')
      lc.annotation = create(:annotation, full_note_en: ' ')
      lc
    end
    let(:lc2) do
      lc = create_cites_I_addition(effective_at: '2014-11-17')
      lc.annotation = create(:annotation, full_note_en: nil)
      lc
    end
    specify { lc1.duplicates(taxon_concept_id: lc2.taxon_concept_id) }
  end
end
