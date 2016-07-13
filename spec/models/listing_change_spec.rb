# == Schema Information
#
# Table name: listing_changes
#
#  id                         :integer          not null, primary key
#  taxon_concept_id           :integer          not null
#  species_listing_id         :integer
#  change_type_id             :integer          not null
#  annotation_id              :integer
#  hash_annotation_id         :integer
#  effective_at               :datetime         default(2012-09-21 07:32:20 UTC), not null
#  is_current                 :boolean          default(FALSE), not null
#  parent_id                  :integer
#  inclusion_taxon_concept_id :integer
#  event_id                   :integer
#  original_id                :integer
#  explicit_change            :boolean          default(TRUE)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  import_row_id              :integer
#  created_by_id              :integer
#  updated_by_id              :integer
#  nomenclature_note_en       :text
#  nomenclature_note_es       :text
#  nomenclature_note_fr       :text
#  internal_notes             :text
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
        specify { listing_change.should be_valid }
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
        specify { listing_change.should have(1).error_on(:inclusion_taxon_concept_id) }
      end
      context "species listing designation mismatch" do
        let(:designation1) { create(:designation) }
        let(:designation2) { create(:designation) }
        let(:listing_change) {
          build(
            :listing_change,
            :species_listing => create(:species_listing, :designation => designation1),
            :change_type => create(:change_type, :designation => designation2)
          )
        }
        specify { listing_change.should have(1).error_on(:species_listing_id) }
      end
      context "event designation mismatch" do
        let(:designation1) { create(:designation) }
        let(:designation2) { create(:designation) }
        let(:listing_change) {
          build(
            :listing_change,
            :event_id => create(:event, :designation => designation1).id,
            :change_type => create(:change_type, :designation => designation2)
          )
        }
        specify { listing_change.should have(1).error_on(:event_id) }
      end
    end
  end
  describe :effective_at_formatted do
    let(:listing_change) { create_cites_I_addition(:effective_at => '2012-05-10') }
    specify { listing_change.effective_at_formatted.should == '10/05/2012' }
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
