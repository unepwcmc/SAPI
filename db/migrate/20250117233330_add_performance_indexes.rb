class AddPerformanceIndexes < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      add_index :api_requests, [
        :user_id, :created_at, :response_status
      ]

      add_index :api_requests, [
        :user_id, :response_status, :created_at
      ]

      add_index :api_requests, [
        :response_status, :created_at
      ]

      add_index :api_requests, [
        :controller, :action, :response_status, :created_at
      ]

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
