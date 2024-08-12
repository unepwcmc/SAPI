# == Schema Information
#
# Table name: cites_listing_changes_mview
#
#  id                         :integer          primary key
#  ann_symbol                 :string(255)
#  auto_note_en               :text
#  auto_note_es               :text
#  auto_note_fr               :text
#  change_type_name           :string(255)
#  designation_name           :string(255)
#  dirty                      :boolean
#  display_in_footnote        :boolean
#  display_in_index           :boolean
#  effective_at               :datetime
#  excluded_geo_entities_ids  :integer          is an Array
#  excluded_taxon_concept_ids :integer          is an Array
#  expiry                     :timestamptz
#  explicit_change            :boolean
#  full_note_en               :text
#  full_note_es               :text
#  full_note_fr               :text
#  geo_entity_type            :string(255)
#  hash_ann_parent_symbol     :string(255)
#  hash_ann_symbol            :string(255)
#  hash_full_note_en          :text
#  hash_full_note_es          :text
#  hash_full_note_fr          :text
#  inherited_full_note_en     :text
#  inherited_full_note_es     :text
#  inherited_full_note_fr     :text
#  inherited_short_note_en    :text
#  inherited_short_note_es    :text
#  inherited_short_note_fr    :text
#  is_current                 :boolean
#  listed_geo_entities_ids    :integer          is an Array
#  nomenclature_note_en       :text
#  nomenclature_note_es       :text
#  nomenclature_note_fr       :text
#  party_full_name_en         :string(255)
#  party_full_name_es         :string(255)
#  party_full_name_fr         :string(255)
#  party_iso_code             :string(255)
#  short_note_en              :text
#  short_note_es              :text
#  short_note_fr              :text
#  show_in_downloads          :boolean
#  show_in_history            :boolean
#  show_in_timeline           :boolean
#  species_listing_name       :string(255)
#  updated_at                 :datetime
#  change_type_id             :integer
#  designation_id             :integer
#  event_id                   :integer
#  inclusion_taxon_concept_id :integer
#  original_taxon_concept_id  :integer
#  parent_id                  :integer
#  party_id                   :integer
#  species_listing_id         :integer
#  taxon_concept_id           :integer
#

class MCitesListingChange < ApplicationRecord
  self.table_name = :cites_listing_changes_mview
  self.primary_key = :id
  include MListingChange
end
