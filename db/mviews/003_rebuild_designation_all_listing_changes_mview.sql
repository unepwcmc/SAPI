CREATE OR REPLACE VIEW all_listing_changes_view AS
  -- affected_taxon_concept is a taxon concept that is affected by this listing
  -- change, even though it might not have an explicit connection to it
  -- (i.e. it is an ancestor's listing change).
  WITH designations_and_intervals AS (
    SELECT
      designations.id          designation_id,
      designations.name        designation_name,
      designations.taxonomy_id taxonomy_id,
      intervals.start_date     interval_start_date,
      intervals.end_date       interval_end_date,
      intervals.events_ids     interval_events_ids
    FROM designations
    LEFT JOIN eu_regulations_applicability_view intervals
      ON designations.name = 'EU'
  ), listing_changes_with_exceptions AS (
    -- the purpose of this CTE is to aggregate excluded taxon concept ids
    SELECT
      listing_changes.id,
      change_types.designation_id,
      change_types.name AS change_type_name,
      listing_changes.taxon_concept_id,
      listing_changes.species_listing_id,
      listing_changes.change_type_id,
      listing_changes.inclusion_taxon_concept_id,
      listing_changes.event_id,
      listing_changes.effective_at::DATE,
      listing_changes.is_current,
      ARRAY_AGG_NOTNULL(taxonomic_exceptions.taxon_concept_id) AS excluded_taxon_concept_ids
    FROM listing_changes
    LEFT JOIN listing_changes taxonomic_exceptions
    ON listing_changes.id = taxonomic_exceptions.parent_id
    AND listing_changes.taxon_concept_id != taxonomic_exceptions.taxon_concept_id
    JOIN change_types ON change_types.id = listing_changes.change_type_id
    JOIN designations_and_intervals
      ON designations_and_intervals.designation_id = change_types.designation_id
      AND (
        designations_and_intervals IS NULL
        OR ARRAY_UPPER(designations_and_intervals.interval_events_ids, 1) IS NULL
        OR listing_changes.event_id = ANY(designations_and_intervals.interval_events_ids)
      )
    GROUP BY
      listing_changes.id,
      change_types.designation_id,
      change_types.name,
      listing_changes.taxon_concept_id,
      listing_changes.species_listing_id,
      listing_changes.change_type_id,
      listing_changes.inclusion_taxon_concept_id,
      listing_changes.event_id,
      listing_changes.effective_at::DATE,
      listing_changes.is_current
  ), aggregate_lc AS (
  -- the purpose of this CTE is to aggregate listed and excluded populations
  SELECT lc.id,
    lc.designation_id,
    lc.change_type_name,
    lc.taxon_concept_id,
    lc.species_listing_id,
    lc.change_type_id,
    lc.inclusion_taxon_concept_id,
    lc.event_id,
    lc.effective_at,
    lc.is_current,
    lc.excluded_taxon_concept_ids,
    party_distribution.geo_entity_id AS party_id,
    ARRAY_AGG_NOTNULL(listing_distributions.geo_entity_id) AS listed_geo_entities_ids,
    ARRAY_AGG_NOTNULL(excluded_distributions.geo_entity_id) AS excluded_geo_entities_ids
  FROM listing_changes_with_exceptions lc
  LEFT JOIN listing_distributions
    ON lc.id = listing_distributions.listing_change_id
    AND NOT listing_distributions.is_party
  LEFT JOIN listing_distributions party_distribution
    ON lc.id = party_distribution.listing_change_id
    AND party_distribution.is_party
  LEFT JOIN listing_changes population_exceptions
    ON lc.id = population_exceptions.parent_id
    AND lc.taxon_concept_id = population_exceptions.taxon_concept_id
  LEFT JOIN listing_distributions excluded_distributions
    ON population_exceptions.id = excluded_distributions.listing_change_id
    AND NOT excluded_distributions.is_party
  GROUP BY
    lc.id,
    lc.designation_id,
    lc.change_type_name,
    lc.taxon_concept_id,
    lc.species_listing_id,
    lc.change_type_id,
    lc.inclusion_taxon_concept_id,
    lc.event_id,
    lc.effective_at,
    lc.is_current,
    party_distribution.geo_entity_id,
    lc.excluded_taxon_concept_ids
)
SELECT
  lc.*,
  tc.taxon_concept_id AS affected_taxon_concept_id,
  -- Make the tree distance reflect distance from inclusion
  -- TODO TEST Rhinopittecus roxellana
  COALESCE(itc.tree_distance, tc.tree_distance) tree_distance,
  -- the following ROW_NUMBER call will assign chronological order to listing changes
  -- in scope of the affected taxon concept and a particular designation
  ROW_NUMBER() OVER (
    PARTITION BY tc.taxon_concept_id, designation_id
    ORDER BY effective_at,
    CASE
      WHEN change_type_name = 'DELETION' THEN 0
      WHEN change_type_name = 'RESERVATION_WITHDRAWAL' THEN 1
      WHEN change_type_name = 'ADDITION' THEN 2
      WHEN change_type_name = 'RESERVATION' THEN 3
      WHEN change_type_name = 'EXCEPTION' THEN 4
    END,
    tc.tree_distance
    -- ??? OR would it be better to
    -- COALESCE(itc.tree_distance, tc.tree_distance) tree_distance
  )::INT AS timeline_position
FROM aggregate_lc lc
JOIN taxon_concepts_and_ancestors_mview tc
  ON lc.taxon_concept_id = tc.ancestor_taxon_concept_id
LEFT JOIN taxon_concepts_and_ancestors_mview itc
  ON lc.inclusion_taxon_concept_id = itc.ancestor_taxon_concept_id
  AND lc.taxon_concept_id = itc.taxon_concept_id
;

DROP FUNCTION IF EXISTS rebuild_designation_all_listing_changes_mview(
  taxonomy taxonomies, designation designations
);

CREATE OR REPLACE VIEW all_listing_changes_view AS
    -- affected_taxon_concept -- is a taxon concept that is affected by this listing change,
    -- even though it might not have an explicit connection to it
    -- (i.e. it''s an ancestor''s listing change)
    WITH listing_changes_with_exceptions AS (
      -- the purpose of this CTE is to aggregate excluded taxon concept ids
      SELECT
        listing_changes.id,
        change_types.designation_id,
        change_types.name AS change_type_name,
        listing_changes.taxon_concept_id,
        listing_changes.species_listing_id,
        listing_changes.change_type_id,
        listing_changes.inclusion_taxon_concept_id,
        listing_changes.event_id,
        listing_changes.effective_at::DATE,
        listing_changes.is_current,
        ARRAY_AGG_NOTNULL(taxonomic_exceptions.taxon_concept_id) AS excluded_taxon_concept_ids
      FROM listing_changes
      LEFT JOIN listing_changes taxonomic_exceptions
      ON listing_changes.id = taxonomic_exceptions.parent_id
      AND listing_changes.taxon_concept_id != taxonomic_exceptions.taxon_concept_id
      JOIN change_types ON change_types.id = listing_changes.change_type_id
      AND change_types.designation_id = ' || designation.id
      || CASE
      WHEN events_ids IS NOT NULL AND ARRAY_UPPER(events_ids, 1) IS NOT NULL
      THEN ' WHERE listing_changes.event_id = ANY (''{' || ARRAY_TO_STRING(events_ids, ', ') || '}''::INT[])'
      ELSE ''
      END ||
      '
      GROUP BY
        listing_changes.id,
        change_types.designation_id,
        change_types.name,
        listing_changes.taxon_concept_id,
        listing_changes.species_listing_id,
        listing_changes.change_type_id,
        listing_changes.inclusion_taxon_concept_id,
        listing_changes.event_id,
        listing_changes.effective_at::DATE,
        listing_changes.is_current
    )
    -- the purpose of this CTE is to aggregate listed and excluded populations
    SELECT lc.id,
      lc.designation_id,
      lc.change_type_name,
      lc.taxon_concept_id,
      lc.species_listing_id,
      lc.change_type_id,
      lc.inclusion_taxon_concept_id,
      lc.event_id,
      lc.effective_at,
      lc.is_current,
      lc.excluded_taxon_concept_ids,
      party_distribution.geo_entity_id AS party_id,
      ARRAY_AGG_NOTNULL(listing_distributions.geo_entity_id) AS listed_geo_entities_ids,
      ARRAY_AGG_NOTNULL(excluded_distributions.geo_entity_id) AS excluded_geo_entities_ids
    FROM listing_changes_with_exceptions lc
    LEFT JOIN listing_distributions
    ON lc.id = listing_distributions.listing_change_id AND NOT listing_distributions.is_party
    LEFT JOIN listing_distributions party_distribution
    ON lc.id = party_distribution.listing_change_id AND party_distribution.is_party
    LEFT JOIN listing_changes population_exceptions
    ON lc.id = population_exceptions.parent_id
    AND lc.taxon_concept_id = population_exceptions.taxon_concept_id
    LEFT JOIN listing_distributions excluded_distributions
    ON population_exceptions.id = excluded_distributions.listing_change_id AND NOT excluded_distributions.is_party
    GROUP BY lc.id,
      lc.designation_id,
      lc.change_type_name,
      lc.taxon_concept_id,
      lc.species_listing_id,
      lc.change_type_id,
      lc.inclusion_taxon_concept_id,
      lc.event_id,
      lc.effective_at,
      lc.is_current,
      party_distribution.geo_entity_id,
      lc.excluded_taxon_concept_ids
;

CREATE OR REPLACE FUNCTION rebuild_designation_all_listing_changes_mview(
  taxonomy taxonomies,
  designation designations,
  events_ids INT[]
) RETURNS void
  LANGUAGE plpgsql
AS $rebuild_designation_all_listing_changes_mview$
  DECLARE
    all_lc_table_name TEXT;
    tmp_lc_table_name TEXT;
    tc_table_name TEXT;
    sql TEXT;
  BEGIN
    SELECT listing_changes_mview_name('all', designation.name, events_ids)
      INTO all_lc_table_name;
    SELECT listing_changes_mview_name('tmp', designation.name, events_ids)
      INTO tmp_lc_table_name;

    SELECT LOWER(taxonomy.name) || '_taxon_concepts_and_ancestors_view'
      INTO tc_table_name;

    -- First, build the temp table
    EXECUTE format(
      $format$
        CREATE TABLE %I AS
          SELECT *
          FROM all_listing_changes_view
          WHERE designation_id = %L
            %S
      $format$,
      tmp_lc_table_name,
      designation.id,
      CASE
        WHEN array_length(events_ids, 1) > 0
        THEN format(
          'AND event_ids = %L::INT[]'
          event_ids
        )
        ELSE ''
      END
    );

    -- Then, drop the old table and swap in the temp table.
    EXECUTE format(
      $format$
        DROP TABLE IF EXISTS %1$I CASCADE;
        ALTER %2$I RENAME TO %1$I;
      $format$,
      all_lc_table_name,
      tmp_lc_table_name
    );

    EXECUTE format(
      $format$
        CREATE INDEX ON %1$I (taxon_concept_id) WHERE is_current;
        CREATE INDEX ON %1$I (taxon_concept_id);
        CREATE INDEX ON %1$I (
          taxon_concept_id,
          is_current,
          change_type_name,
          inclusion_taxon_concept_id
        );
        CREATE INDEX ON %1%I (designation_id, timeline_position, affected_taxon_concept_id)
        CREATE INDEX ON %1%I (affected_taxon_concept_id, inclusion_taxon_concept_id)
        CREATE INDEX ON %1%I (id, affected_taxon_concept_id)
        CREATE INDEX ON %1$I (affected_taxon_concept_id, id);
      $format$,
      all_lc_table_name
    );
  END;
$rebuild_designation_all_listing_changes_mview$;

COMMENT ON FUNCTION rebuild_designation_all_listing_changes_mview(
  taxonomy taxonomies,
  designation designations,
  events_ids INT[]
) IS $comment$
Procedure to create a helper table with all listing changes
+ their included / excluded populations
+ tree distance between affected taxon concept and the taxon concept this listing change applies to.
$comment$;
