# == Schema Information
#
# Table name: auto_complete_taxon_concepts_mview
#
#  id                        :integer          primary key
#  taxonomy_is_cites_eu      :boolean
#  name_status               :string(255)
#  rank_name                 :string(255)
#  rank_display_name_en      :text
#  rank_display_name_es      :text
#  rank_display_name_fr      :text
#  rank_order                :string(255)
#  taxonomic_position        :string(255)
#  show_in_species_plus_ac   :boolean
#  show_in_checklist_ac      :boolean
#  show_in_trade_ac          :boolean
#  show_in_trade_internal_ac :boolean
#  name_for_matching         :text
#  matched_id                :integer
#  matched_name              :string(255)
#  full_name                 :string(255)
#  type_of_match             :text
#

class MAutoCompleteTaxonConcept < ActiveRecord::Base
  self.table_name = :auto_complete_taxon_concepts_mview
  self.primary_key = :id
  scope :by_cites_eu_taxonomy, -> { where(:taxonomy_is_cites_eu => true) }
  scope :by_cms_taxonomy, -> { where(:taxonomy_is_cites_eu => false) }
  translates :rank_display_name
  def matching_names
    read_attribute(:matching_names_ary) || []
  end
end
