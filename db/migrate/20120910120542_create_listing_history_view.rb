class CreateListingHistoryView < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW listing_changes_view AS
      SELECT
        listing_changes.id AS id,
        taxon_concept_id, effective_at,
        species_listing_id,
        species_listings.abbreviation AS species_listing_name,
        change_type_id, change_types.name AS change_type_name,
        listing_distributions.geo_entity_id AS party_id,
        geo_entities.iso_code2 AS party_name,
        notes
      FROM
        listing_changes
        LEFT JOIN change_types
          ON listing_changes.change_type_id = change_types.id
        LEFT JOIN species_listings
          ON listing_changes.species_listing_id = species_listings.id
        LEFT JOIN listing_distributions
          ON listing_changes.id = listing_distributions.listing_change_id
          AND listing_distributions.is_party = 't'
        LEFT JOIN geo_entities ON
          geo_entities.id = listing_distributions.geo_entity_id
      ORDER BY taxon_concept_id, effective_at,
      CASE
        WHEN change_types.name = 'ADDITION' THEN 0
        WHEN change_types.name = 'RESERVATION' THEN 1
        WHEN change_types.name = 'RESERVATION_WITHDRAWAL' THEN 2
        WHEN change_types.name = 'DELETION' THEN 3
      END
    SQL
  end

  def down
    execute "DROP VIEW listing_changes_view"
  end
end
