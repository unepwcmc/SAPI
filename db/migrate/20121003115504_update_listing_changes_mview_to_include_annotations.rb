class UpdateListingChangesMviewToIncludeAnnotations < ActiveRecord::Migration
  def up
    execute <<-SQL
      DROP VIEW listing_changes_view;
      CREATE VIEW listing_changes_view AS
      SELECT
        listing_changes.id AS id,
        taxon_concept_id, effective_at,
        species_listing_id,
        species_listings.abbreviation AS species_listing_name,
        change_type_id, change_types.name AS change_type_name,
        listing_distributions.geo_entity_id AS party_id,
        geo_entities.iso_code2 AS party_name,
        multilingual_annotations.english_full_note,
        multilingual_annotations.spanish_full_note,
        multilingual_annotations.french_full_note
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
        LEFT JOIN annotations ON
          annotations.listing_change_id = listing_changes.id
        LEFT JOIN (
          SELECT *
          FROM
          CROSSTAB(
            'SELECT annotations.id AS annotation_id_mul,
            SUBSTRING(languages.name FROM 1 FOR 1) AS lng,
            annotation_translations.full_note
            FROM "annotations"
            INNER JOIN "annotation_translations"
              ON "annotation_translations"."annotation_id" = "annotations"."id" 
            INNER JOIN "languages"
              ON "languages"."id" = "annotation_translations"."language_id"
            ORDER BY 1,2'
          ) AS ct(
            annotation_id_mul INTEGER,
            english_full_note TEXT, spanish_full_note TEXT, french_full_note TEXT
          )
        ) multilingual_annotations ON annotations.id = multilingual_annotations.annotation_id_mul
      ORDER BY taxon_concept_id, effective_at,
      CASE
        WHEN change_types.name = 'ADDITION' THEN 0
        WHEN change_types.name = 'RESERVATION' THEN 1
        WHEN change_types.name = 'RESERVATION_WITHDRAWAL' THEN 2
        WHEN change_types.name = 'DELETION' THEN 3
      END
    SQL
    Sapi::rebuild_listing_changes_mview
  end

  def down
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
end
