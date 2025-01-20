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

      add_index :listing_distributions, [
        :listing_change_id, :geo_entity_id
      ]
    end
  end
end
