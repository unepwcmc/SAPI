# == Schema Information
#
# Table name: auto_complete_taxon_concepts_mview
#
#  id                        :integer          primary key
#  author_year               :string(255)
#  full_name                 :string(255)
#  matched_name              :string(255)
#  name_for_matching         :text
#  name_status               :string(255)
#  rank_display_name_en      :text
#  rank_display_name_es      :text
#  rank_display_name_fr      :text
#  rank_name                 :string(255)
#  rank_order                :string(255)
#  show_in_checklist_ac      :boolean
#  show_in_species_plus_ac   :boolean
#  show_in_trade_ac          :boolean
#  show_in_trade_internal_ac :boolean
#  taxonomic_position        :string(255)
#  taxonomy_is_cites_eu      :boolean
#  type_of_match             :text
#  matched_id                :integer
#
# Indexes
#
#  auto_complete_taxon_concepts__name_for_matching_taxonomy_i_idx1  (name_for_matching,taxonomy_is_cites_eu,type_of_match,show_in_checklist_ac)
#  auto_complete_taxon_concepts__name_for_matching_taxonomy_i_idx2  (name_for_matching,taxonomy_is_cites_eu,type_of_match,show_in_trade_ac)
#  auto_complete_taxon_concepts__name_for_matching_taxonomy_i_idx7  (name_for_matching,taxonomy_is_cites_eu,type_of_match,show_in_trade_internal_ac)
#  auto_complete_taxon_concepts__name_for_matching_taxonomy_is_idx  (name_for_matching,taxonomy_is_cites_eu,type_of_match,show_in_species_plus_ac)
#

class MAutoCompleteTaxonConcept < ApplicationRecord
  extend Mobility
  self.table_name = :auto_complete_taxon_concepts_mview
  self.primary_key = :id
  scope :by_cites_eu_taxonomy, -> { where(taxonomy_is_cites_eu: true) }
  scope :by_cms_taxonomy, -> { where(taxonomy_is_cites_eu: false) }
  translates :rank_display_name
  def matching_names
    read_attribute(:matching_names_ary) || []
  end
end
