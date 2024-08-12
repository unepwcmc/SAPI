# == Schema Information
#
# Table name: listing_changes
#
#  id                         :integer          not null, primary key
#  effective_at               :datetime         default(Fri, 21 Sep 2012 07:32:20.000000000 UTC +00:00), not null
#  explicit_change            :boolean          default(TRUE)
#  internal_notes             :text
#  is_current                 :boolean          default(FALSE), not null
#  nomenclature_note_en       :text
#  nomenclature_note_es       :text
#  nomenclature_note_fr       :text
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  annotation_id              :integer
#  change_type_id             :integer          not null
#  created_by_id              :integer
#  event_id                   :integer
#  hash_annotation_id         :integer
#  import_row_id              :integer
#  inclusion_taxon_concept_id :integer
#  original_id                :integer
#  parent_id                  :integer
#  species_listing_id         :integer
#  taxon_concept_id           :integer          not null
#  updated_by_id              :integer
#
# Indexes
#
#  index_listing_changes_on_annotation_id               (annotation_id)
#  index_listing_changes_on_event_id                    (event_id)
#  index_listing_changes_on_hash_annotation_id          (hash_annotation_id)
#  index_listing_changes_on_inclusion_taxon_concept_id  (inclusion_taxon_concept_id)
#  index_listing_changes_on_parent_id                   (parent_id)
#  index_listing_changes_on_taxon_concept_id            (taxon_concept_id)
#
# Foreign Keys
#
#  listing_changes_annotation_id_fk               (annotation_id => annotations.id)
#  listing_changes_change_type_id_fk              (change_type_id => change_types.id)
#  listing_changes_created_by_id_fk               (created_by_id => users.id)
#  listing_changes_event_id_fk                    (event_id => events.id)
#  listing_changes_hash_annotation_id_fk          (hash_annotation_id => annotations.id)
#  listing_changes_inclusion_taxon_concept_id_fk  (inclusion_taxon_concept_id => taxon_concepts.id)
#  listing_changes_parent_id_fk                   (parent_id => listing_changes.id)
#  listing_changes_source_id_fk                   (original_id => listing_changes.id)
#  listing_changes_species_listing_id_fk          (species_listing_id => species_listings.id)
#  listing_changes_taxon_concept_id_fk            (taxon_concept_id => taxon_concepts.id)
#  listing_changes_updated_by_id_fk               (updated_by_id => users.id)
#

require 'spec_helper'

describe ListingChange do
  context "validations" do
    describe :create do
      context "all fine with exception" do
        let!(:exception_type) { cites_exception }
        let(:taxon_concept) { create_cites_eu_species }
        let(:excluded_taxon_concept) { create_cites_eu_subspecies(parent: taxon_concept) }
        let(:listing_change) {
          build(
            :listing_change,
            change_type: cites_addition,
            species_listing: cites_I,
            taxon_concept: taxon_concept,
            excluded_taxon_concepts_ids: "#{excluded_taxon_concept.id}"
          )
        }
        specify { expect(listing_change).to be_valid }
      end
      context "inclusion taxon concept is lower rank" do
        let(:inclusion) { create_cites_eu_subspecies }
        let(:taxon_concept) { create_cites_eu_species }
        let(:listing_change) {
          build(
            :listing_change,
            taxon_concept: taxon_concept,
            inclusion_taxon_concept_id: inclusion.id
          )
        }
        specify { expect(listing_change.error_on(:inclusion_taxon_concept_id).size).to eq(1) }
      end
      context "species listing designation mismatch" do
        let(:designation1) { create(:designation) }
        let(:designation2) { create(:designation) }
        let(:listing_change) {
          build(
            :listing_change,
            species_listing: create(:species_listing, designation: designation1),
            change_type: create(:change_type, designation: designation2)
          )
        }
        specify { expect(listing_change.error_on(:species_listing_id).size).to eq(1) }
      end
      context "event designation mismatch" do
        let(:designation1) { create(:designation) }
        let(:designation2) { create(:designation) }
        let(:listing_change) {
          build(
            :listing_change,
            event_id: create(:event, designation: designation1).id,
            change_type: create(:change_type, designation: designation2)
          )
        }
        specify { expect(listing_change.error_on(:event_id).size).to eq(1) }
      end
    end
  end
  describe :effective_at_formatted do
    let(:listing_change) { create_cites_I_addition(effective_at: '2012-05-10') }
    specify { expect(listing_change.effective_at_formatted).to eq('10/05/2012') }
  end

  describe :duplicates do
    let(:lc1) {
      lc = create_cites_I_addition(effective_at: '2014-11-17')
      lc.annotation = create(:annotation, full_note_en: ' ')
      lc
    }
    let(:lc2) {
      lc = create_cites_I_addition(effective_at: '2014-11-17')
      lc.annotation = create(:annotation, full_note_en: nil)
      lc
    }
    specify { lc1.duplicates(taxon_concept_id: lc2.taxon_concept_id) }
  end
end
