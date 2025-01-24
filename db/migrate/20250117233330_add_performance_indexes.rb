class AddPerformanceIndexes < ActiveRecord::Migration[7.1]
  def change
    # These lock tables for writes, but these tables are generally only written
    # to by WCMC staff so we can handle a short period of downtime here.
    safety_assured do
      add_index :listing_changes, [
        :taxon_concept_id, :change_type_id, :species_listing_id
      ]

      add_index :listing_changes, [
        :taxon_concept_id, :species_listing_id, :change_type_id
      ]

      add_index :listing_changes, [
        :taxon_concept_id, :change_type_id, :species_listing_id
      ], where: 'is_current', name: 'idx_listing_changes_where_is_current_on_taxon_type_listing'

      add_index :listing_distributions, [
        :listing_change_id, :geo_entity_id
      ]

      add_index :events, [
        :type, :subtype, :designation_id
      ]

      add_index :events, [
        :type, :subtype, :designation_id
      ], where: 'is_current', name: 'idx_events_where_is_current_on_type_subtype_designation'

      add_index :trade_restrictions, [
        :is_current, :type, :taxon_concept_id
      ]

      # complement to unique index on columns
      # ancestor_taxon_concept_id, taxon_concept_id
      add_index :taxon_concepts_and_ancestors_mview, [
        :taxon_concept_id, :ancestor_taxon_concept_id, :tree_distance
      ]
    end
  end
end
