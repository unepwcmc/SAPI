class CreateCascadedListingChangesView < ActiveRecord::Migration
  def change
execute <<-SQL
    DROP VIEW IF EXISTS listing_changes_view;
    CREATE VIEW listing_changes_view AS
    WITH applicable_listing_changes AS (
      SELECT taxon_concepts.id AS taxon_concept_id, applicable_listing_changes_for_node(taxon_concepts.id) AS id
      FROM taxon_concepts
    )
    SELECT
    applicable_listing_changes.taxon_concept_id AS taxon_concept_id,
    listing_changes.id AS id,
    listing_changes.taxon_concept_id AS original_taxon_concept_id,
    effective_at,
    species_listing_id,
    species_listings.abbreviation AS species_listing_name,
    change_type_id, change_types.name AS change_type_name,
    change_types.designation_id AS designation_id,
    designations.name AS designation_name,
    listing_distributions.geo_entity_id AS party_id,
    geo_entities.iso_code2 AS party_iso_code,
    annotations.symbol AS ann_symbol,
    annotations.full_note_en,
    annotations.full_note_es,
    annotations.full_note_fr,
    annotations.short_note_en,
    annotations.short_note_es,
    annotations.short_note_fr,
    annotations.display_in_index,
    annotations.display_in_footnote,
    hash_annotations.symbol AS hash_ann_symbol,
    hash_annotations.parent_symbol AS hash_ann_parent_symbol,
    hash_annotations.full_note_en AS hash_full_note_en,
    hash_annotations.full_note_es AS hash_full_note_es,
    hash_annotations.full_note_fr AS hash_full_note_fr,
    listing_changes.is_current,
    listing_changes.explicit_change,
    populations.countries_ids_ary
    FROM
    applicable_listing_changes
    JOIN listing_changes On applicable_listing_changes.id  = listing_changes.id
    INNER JOIN change_types
    ON listing_changes.change_type_id = change_types.id
    INNER JOIN designations
    ON change_types.designation_id = designations.id
    LEFT JOIN species_listings
    ON listing_changes.species_listing_id = species_listings.id
    LEFT JOIN listing_distributions
    ON listing_changes.id = listing_distributions.listing_change_id
    AND listing_distributions.is_party = 't'
    LEFT JOIN geo_entities ON
    geo_entities.id = listing_distributions.geo_entity_id
    LEFT JOIN annotations ON
    annotations.id = listing_changes.annotation_id
    LEFT JOIN annotations hash_annotations ON
    hash_annotations.id = listing_changes.hash_annotation_id
    LEFT JOIN (
    SELECT listing_change_id, ARRAY_AGG(geo_entities.id) AS countries_ids_ary
    FROM listing_distributions
    INNER JOIN geo_entities
    ON geo_entities.id = listing_distributions.geo_entity_id
    WHERE NOT is_party
    GROUP BY listing_change_id
    ) populations ON populations.listing_change_id = listing_changes.id
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
end
