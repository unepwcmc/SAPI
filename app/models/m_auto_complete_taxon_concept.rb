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
#  idx_ac_taxon_checklist_btree       (name_for_matching,type_of_match) WHERE (taxonomy_is_cites_eu AND show_in_checklist_ac)
#  idx_ac_taxon_checklist_gist        (name_for_matching) WHERE (taxonomy_is_cites_eu AND show_in_checklist_ac) USING gist
#  idx_ac_taxon_gist                  (name_for_matching) USING gist
#  idx_ac_taxon_splus_btree           (name_for_matching,taxonomy_is_cites_eu,type_of_match) WHERE show_in_species_plus_ac
#  idx_ac_taxon_splus_gist            (name_for_matching) WHERE show_in_species_plus_ac USING gist
#  idx_ac_taxon_trade_ac_btree        (name_for_matching,type_of_match,taxonomy_is_cites_eu) WHERE show_in_trade_ac
#  idx_ac_taxon_trade_ac_gist         (name_for_matching) WHERE show_in_trade_ac USING gist
#  idx_ac_taxon_trade_internal_btree  (name_for_matching,type_of_match,taxonomy_is_cites_eu) WHERE show_in_trade_internal_ac
#  idx_ac_taxon_trade_internal_gist   (name_for_matching) WHERE show_in_trade_internal_ac USING gist
#

class MAutoCompleteTaxonConcept < ApplicationRecord
  extend Mobility
  self.table_name = :auto_complete_taxon_concepts_mview
  self.primary_key = :id

  scope :by_cites_eu_taxonomy, -> { where(taxonomy_is_cites_eu: true) }
  scope :by_cms_taxonomy, -> { where(taxonomy_is_cites_eu: false) }
  belongs_to :taxon_concept

  translates :rank_display_name

  def matching_names
    self[:matching_names_ary] || []
  end

  def self.where_prefix_matches(prefix_query)
    return self unless prefix_query&.present?

    where(
      (
        <<-SQL.squish
          name_for_matching LIKE unaccent(upper(:prefix_query)) || '%'
        SQL
      ),
      prefix_query: prefix_query && sanitize_sql_like(prefix_query.squish)
    )
  end

  def self.where_substring_matches(substring_query)
    return self unless substring_query&.present?

    where(
      (
        <<-SQL.squish
          name_for_matching LIKE '%' || unaccent(upper(:substring_query)) || '%'
        SQL
      ),
      substring_query: substring_query && sanitize_sql_like(substring_query.squish)
    )
  end

  def self.where_fuzzily_matches(fuzzy_query)
    return self.where('FALSE') unless fuzzy_query&.present?

    where(
      # Match score of 0.6 or lower. (Lower is better match, 0 is identity)
      'name_for_matching % unaccent(upper(:fuzzy_query))',
      fuzzy_query:
    ).order_by_fuzzy_match_on(fuzzy_query)
  end

  def self.order_by_fuzzy_match_on(fuzzy_query)
    return self.where('FALSE') unless fuzzy_query&.present?

    order(
      [
        Arel.sql(
          'name_for_matching <-> unaccent(upper(:fuzzy_query))',
          fuzzy_query: fuzzy_query.squish
        )
      ]
    )
  end
end
