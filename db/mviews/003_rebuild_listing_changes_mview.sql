CREATE OR REPLACE FUNCTION strip_tags(TEXT) RETURNS TEXT
  LANGUAGE SQL IMMUTABLE
  AS $$
    SELECT regexp_replace(regexp_replace($1, E'(?x)<[^>]*?(\s alt \s* = \s* ([\'"]) ([^>]*?) \2) [^>]*? >', E'\3'), E'(?x)(< [^>]*? >)', '', 'g')
  $$;

CREATE OR REPLACE FUNCTION full_name_with_spp(rank_name VARCHAR(255), full_name VARCHAR(255)) RETURNS VARCHAR(255)
  LANGUAGE sql IMMUTABLE
  AS $$
    SELECT CASE
      WHEN $1 IN ('ORDER', 'FAMILY', 'GENUS')
      THEN $2 || ' spp.'
      ELSE $2
    END;
  $$;

CREATE OR REPLACE FUNCTION ancestor_listing_auto_note(rank_name VARCHAR(255), full_name VARCHAR(255))
RETURNS TEXT
  LANGUAGE sql IMMUTABLE
  AS $$
    SELECT $1 || ' listing: ' || full_name_with_spp($1, $2);
  $$;

CREATE OR REPLACE FUNCTION rebuild_listing_changes_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    PERFORM rebuild_all_listing_changes_mview();

    RAISE NOTICE 'Dropping listing changes materialized view';
    DROP table IF EXISTS listing_changes_mview CASCADE;

    RAISE NOTICE 'Dropping listing changes view';
    DROP VIEW IF EXISTS listing_changes_view;

    RAISE NOTICE 'Creating listing changes view';
    CREATE VIEW listing_changes_view AS
    WITH applicable_listing_changes AS (
        SELECT designation_id, affected_taxon_concept_id,
        applicable_listing_changes_for_node(designation_id, affected_taxon_concept_id) AS listing_change_id
        FROM all_listing_changes_mview
        GROUP BY designation_id, affected_taxon_concept_id
    )
    SELECT
    applicable_listing_changes.affected_taxon_concept_id AS taxon_concept_id,
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
    CASE
    WHEN applicable_listing_changes.affected_taxon_concept_id != listing_changes.taxon_concept_id
    THEN ancestor_listing_auto_note(
      original_taxon_concepts.data->'rank_name',
      original_taxon_concepts.full_name
    )
    WHEN inclusion_taxon_concept_id IS NOT NULL
    THEN ancestor_listing_auto_note(
      inclusion_taxon_concepts.data->'rank_name',
      inclusion_taxon_concepts.full_name
    )
    ELSE NULL
    END AS auto_note,
    listing_changes.is_current,
    listing_changes.explicit_change,
    populations.countries_ids_ary,
    CASE
    WHEN change_types.name != 'EXCEPTION' AND listing_changes.explicit_change
    THEN TRUE
    ELSE FALSE
    END AS show_in_history,
    CASE
    WHEN change_types.name != 'EXCEPTION' AND listing_changes.explicit_change
    THEN TRUE
    ELSE FALSE
    END AS show_in_downloads,
    CASE
    WHEN change_types.name != 'EXCEPTION'
    THEN TRUE
    ELSE FALSE
    END AS show_in_timeline
    FROM
    applicable_listing_changes
    JOIN listing_changes ON applicable_listing_changes.listing_change_id  = listing_changes.id
    JOIN taxon_concepts original_taxon_concepts
    ON original_taxon_concepts.id = listing_changes.taxon_concept_id
    LEFT JOIN taxon_concepts inclusion_taxon_concepts
    ON inclusion_taxon_concepts.id = listing_changes.inclusion_taxon_concept_id
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
    END;


    RAISE NOTICE 'Creating listing changes materialized view';
    CREATE TABLE listing_changes_mview AS
    SELECT *,
    false as dirty,
    null::timestamp with time zone as expiry
    FROM listing_changes_view;

    -- now for those taxon concepts that only have inherited legislation,
    -- ignore them in downloads
    WITH taxon_concepts_with_inherited_legislation_only AS (
      SELECT designation_id, taxon_concept_id
      FROM listing_changes_mview
      GROUP BY designation_id, taxon_concept_id
      HAVING EVERY(original_taxon_concept_id != taxon_concept_id)
    )
    UPDATE listing_changes_mview
    SET show_in_downloads = FALSE
    FROM taxon_concepts_with_inherited_legislation_only
    WHERE taxon_concepts_with_inherited_legislation_only.designation_id = listing_changes_mview.designation_id
    AND taxon_concepts_with_inherited_legislation_only.taxon_concept_id = listing_changes_mview.taxon_concept_id;

    RAISE NOTICE 'Creating indexes on listing changes materialized view';
    CREATE INDEX ON listing_changes_mview (show_in_timeline, taxon_concept_id, designation_id);
    CREATE INDEX ON listing_changes_mview (show_in_downloads, taxon_concept_id, designation_id);
    CREATE INDEX ON listing_changes_mview (id);
    CREATE INDEX ON listing_changes_mview (taxon_concept_id);

    --RAISE NOTICE 'Dropping all listing changes materialized view';
   -- DROP table IF EXISTS all_listing_changes_mview CASCADE;
  END;
  $$;
