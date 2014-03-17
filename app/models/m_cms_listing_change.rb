# == Schema Information
#
# Table name: cms_listing_changes_mview
#
#  taxon_concept_id           :integer
#  id                         :integer          primary key
#  original_taxon_concept_id  :integer
#  effective_at               :datetime
#  species_listing_id         :integer
#  species_listing_name       :string(255)
#  change_type_id             :integer
#  change_type_name           :string(255)
#  designation_id             :integer
#  designation_name           :string(255)
#  parent_id                  :integer
#  party_id                   :integer
#  party_iso_code             :string(255)
#  ann_symbol                 :string(255)
#  full_note_en               :text
#  full_note_es               :text
#  full_note_fr               :text
#  short_note_en              :text
#  short_note_es              :text
#  short_note_fr              :text
#  display_in_index           :boolean
#  display_in_footnote        :boolean
#  hash_ann_symbol            :string(255)
#  hash_ann_parent_symbol     :string(255)
#  hash_full_note_en          :text
#  hash_full_note_es          :text
#  hash_full_note_fr          :text
#  inclusion_taxon_concept_id :integer
#  inherited_short_note_en    :text
#  inherited_full_note_en     :text
#  auto_note                  :text
#  is_current                 :boolean
#  explicit_change            :boolean
#  countries_ids_ary          :string
#  updated_at                 :datetime
#  show_in_history            :boolean
#  show_in_downloads          :boolean
#  show_in_timeline           :boolean
#  dirty                      :boolean
#  expiry                     :datetime
#

class MCmsListingChange < ActiveRecord::Base
  self.table_name = :cms_listing_changes_mview
  self.primary_key = :id
  include MListingChange
end
