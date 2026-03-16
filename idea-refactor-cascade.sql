BEGIN;
DROP VIEW IF EXISTS taxon_ancestors_dv CASCADE;
CREATE OR REPLACE VIEW taxon_ancestors_dv AS
  WITH RECURSIVE ancestries AS (
    -- start with the root nodes
    SELECT
      "taxonomy_id",
      "id",
      "rank_id",
      '{}'::BIGINT[] AS "ancestor_ids"
    FROM "taxon_concepts" roots
    WHERE "parent_id" IS NULL
      AND "name_status" = 'A'
  UNION ALL
    SELECT
      "child"."taxonomy_id",
      "child"."id",
      "child"."rank_id",
      "parent"."ancestor_ids" || ARRAY["parent"."id"::BIGINT]
    FROM "ancestries" parent
    JOIN "taxon_concepts" child
      ON "child"."taxonomy_id" = "parent"."taxonomy_id"
      AND "child"."parent_id" = "parent"."id"
  ), taxon_ancestors AS (
    SELECT
      "taxonomy_id", "id", "rank_id",
      unnest(ancestor_ids) AS ancestor_id,
      "ancestor_ids"
    FROM "ancestries"
  ), rank_depths AS (
    SELECT
      "id" AS "rank_id",
      ROW_NUMBER() OVER() AS "rank_depth"
    FROM (
      SELECT (
        '{' || translate(taxonomic_position, '.', ',') || '}'
      )::INT[],
        *
      FROM ranks
      ORDER BY 1
    ) r
  ), rank_distances AS (
    SELECT
      "ancestor_rank"."rank_id"      ancestor_rank_id,
      "ancestor_rank"."rank_depth"   ancestor_rank_depth,
      "descendant_rank"."rank_id"    descendant_rank_id,
      "descendant_rank"."rank_depth" descendant_rank_depth,
      "descendant_rank"."rank_depth" - "ancestor_rank"."rank_depth" AS rank_distance
    FROM "rank_depths" ancestor_rank
    JOIN "rank_depths" descendant_rank
      ON "ancestor_rank"."rank_depth" <= "descendant_rank"."rank_depth"
  )
  SELECT
    "ta"."taxonomy_id",
    "ta"."id",
    "ta"."rank_id",
    "ta"."ancestor_ids",
    "ta"."ancestor_ids"[(
      array_position("ta"."ancestor_ids", "ta"."ancestor_id")
    ):] "path_ids",
    "ta"."ancestor_id",
    "ancestor_rank_id",
    "ancestor_rank_depth",
    "descendant_rank_depth" AS "rank_depth",
    "rd"."rank_distance"
  FROM "taxon_ancestors" ta
  JOIN "taxon_concepts" atc
    ON "ancestor_id" = "atc"."id"
  JOIN "rank_distances" rd
    ON "rd"."descendant_rank_id" = "ta"."rank_id"
    AND "rd"."ancestor_rank_id" = "atc"."rank_id"
;

DROP VIEW IF EXISTS implied_listing_changes_view CASCADE;
CREATE OR REPLACE VIEW implied_listing_changes_view AS
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
  SELECT
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
    PARTITION BY
      tc.taxon_concept_id,
      designation_id,
      -- fix Agapornis fischeri, which has
      --
      -- CH R..W
      -- LI R..W
      lc.party_id
    ORDER BY
      effective_at,
      CASE
        WHEN change_type_name = 'DELETION' THEN 0
        WHEN change_type_name = 'RESERVATION_WITHDRAWAL' THEN 1
        WHEN change_type_name = 'ADDITION' THEN 2
        WHEN change_type_name = 'RESERVATION' THEN 3
        WHEN change_type_name = 'EXCEPTION' THEN 4
      END,
      -- Before 2026 this was ascending, but we want e.g. species listings to take
      -- priority over genus listings.
      tc.tree_distance DESC
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

DROP VIEW IF EXISTS taxon_concepts_with_distributions_and_ancestors CASCADE;
CREATE OR REPLACE VIEW taxon_concepts_with_distributions_and_ancestors AS
SELECT
  tc.*,
  (ancestor_fields->'kingdom_id')::INTEGER    AS kingdom_id,
  (ancestor_fields->'phylum_id')::INTEGER     AS phylum_id,
  (ancestor_fields->'class_id')::INTEGER      AS class_id,
  (ancestor_fields->'order_id')::INTEGER      AS order_id,
  (ancestor_fields->'family_id')::INTEGER     AS family_id,
  (ancestor_fields->'subfamily_id')::INTEGER  AS subfamily_id,
  (ancestor_fields->'genus_id')::INTEGER      AS genus_id,
  (ancestor_fields->'species_id')::INTEGER    AS species_id,
  (ancestor_fields->'subspecies_id')::INTEGER AS subspecies_id,
  td.geo_entity_ids
FROM taxon_concepts tc
JOIN (
  SELECT
    ta.id,
    hstore(
      array_agg(ARRAY[lower(r.name) || '_id', ancestor_id::text])
    ) AS ancestor_fields
  FROM taxon_ancestors_dv ta
  JOIN ranks r ON ta.ancestor_rank_id = r.id
  GROUP BY ta.id
) ta ON tc.id = ta.id
JOIN (
  SELECT
    taxon_concept_id "id",
    array_agg(geo_entity_id) AS geo_entity_ids
  FROM distributions d
  GROUP BY taxon_concept_id
) td ON tc.id = td.id;

DROP VIEW IF EXISTS applicable_listing_changes_timeline_view CASCADE;
CREATE OR REPLACE VIEW applicable_listing_changes_timeline_view AS
WITH RECURSIVE listing_changes_timeline AS (
  SELECT lc.id,
    designation_id,
    affected_taxon_concept_id AS original_taxon_concept_id,
    taxon_concept_id AS current_taxon_concept_id,
    inclusion_taxon_concept_id,
    party_id,
    species_listing_id,
    change_type_id,
    event_id,
    effective_at,
    CASE -- context
      WHEN inclusion_taxon_concept_id IS NULL
      THEN HSTORE(species_listing_id::TEXT, taxon_concept_id::TEXT)
      ELSE HSTORE(species_listing_id::TEXT, inclusion_taxon_concept_id::TEXT)
    END AS context,
    -- CASE WHEN
    --   THEN
    --   ELSE
    HSTORE(tree_distance::TEXT, (lc.id)::TEXT) AS listing_change_ids_by_distance,
    is_current,
    tree_distance AS context_tree_distance,
    timeline_position,
    CASE -- is_applicable
      WHEN (
        -- there are listed populations
        ARRAY_UPPER(listed_geo_entities_ids, 1) IS NOT NULL
        -- and the taxon has its own distribution and does not occur in any of them
        AND ARRAY_UPPER(taxon_concepts_mview.geo_entity_ids, 1) IS NOT NULL
        AND NOT listed_geo_entities_ids && taxon_concepts_mview.geo_entity_ids
      ) OR (
        -- when all populations are excluded
        ARRAY_UPPER(excluded_geo_entities_ids, 1) IS NOT NULL
        AND ARRAY_UPPER(taxon_concepts_mview.geo_entity_ids, 1) IS NOT NULL
        AND excluded_geo_entities_ids @> taxon_concepts_mview.geo_entity_ids
      )
      THEN FALSE
      WHEN ARRAY_UPPER(excluded_taxon_concept_ids, 1) IS NOT NULL
        -- if taxon or any of its ancestors is excluded from this listing
        AND excluded_taxon_concept_ids && ARRAY[
          affected_taxon_concept_id,
          taxon_concepts_mview.kingdom_id,
          taxon_concepts_mview.phylum_id,
          taxon_concepts_mview.class_id,
          taxon_concepts_mview.order_id,
          taxon_concepts_mview.family_id,
          taxon_concepts_mview.genus_id,
          taxon_concepts_mview.species_id
        ]
      THEN FALSE
      ELSE TRUE
    END AS is_applicable
    FROM implied_listing_changes_view lc
    JOIN taxon_concepts_with_distributions_and_ancestors taxon_concepts_mview
      ON lc.affected_taxon_concept_id = taxon_concepts_mview.id
    WHERE timeline_position = 1
    -- AND lc.affected_taxon_concept_id = $1

  UNION

  SELECT
    hi.id,
    hi.designation_id,
    listing_changes_timeline.original_taxon_concept_id,
    hi.taxon_concept_id,
    hi.inclusion_taxon_concept_id,
    hi.party_id,
    hi.species_listing_id,
    hi.change_type_id,
    hi.event_id,
    hi.effective_at,
    CASE -- context
      WHEN hi.inclusion_taxon_concept_id IS NOT NULL
        AND (
          AVALS(listing_changes_timeline.context) @> ARRAY[hi.taxon_concept_id::TEXT]
          OR listing_changes_timeline.context = ''::HSTORE
        )
      THEN HSTORE(hi.species_listing_id::TEXT, hi.inclusion_taxon_concept_id::TEXT)
      WHEN change_types.name = 'DELETION'
        AND hi.taxon_concept_id = hi.affected_taxon_concept_id
      THEN listing_changes_timeline.context - ARRAY[hi.species_listing_id::TEXT]
      WHEN change_types.name = 'DELETION'
      THEN listing_changes_timeline.context - HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
      -- if it is a new listing at closer level that replaces an older listing, wipe out the context
      WHEN hi.tree_distance < listing_changes_timeline.context_tree_distance
        AND hi.effective_at > listing_changes_timeline.effective_at
        AND change_types.name = 'ADDITION'
      THEN HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
      -- if it is a same day split listing we don''t want to wipe the other part of the split from the context
      WHEN hi.tree_distance < listing_changes_timeline.context_tree_distance
        AND change_types.name = 'ADDITION'
        THEN listing_changes_timeline.context || HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
      WHEN hi.tree_distance <= listing_changes_timeline.context_tree_distance
        AND hi.affected_taxon_concept_id = hi.taxon_concept_id
        AND change_types.name = 'ADDITION'
      THEN HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
      -- changing this to <= breaks Ursus arctos isabellinus
      WHEN hi.tree_distance <= listing_changes_timeline.context_tree_distance
        AND change_types.name = 'ADDITION'
      THEN listing_changes_timeline.context || HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
      ELSE listing_changes_timeline.context
    END AS context,
    -- listing_changes_timeline,
    listing_changes_timeline.listing_change_ids_by_distance || HSTORE(
      tree_distance::TEXT, listing_changes_timeline.id::TEXT
    ) AS listing_change_ids_by_distance,
    hi.is_current,
    CASE -- context_tree_distance
      WHEN (
        hi.inclusion_taxon_concept_id IS NOT NULL
        AND AVALS(listing_changes_timeline.context) @> ARRAY[hi.taxon_concept_id::TEXT]
      ) OR hi.tree_distance < listing_changes_timeline.context_tree_distance
      THEN hi.tree_distance
      ELSE listing_changes_timeline.context_tree_distance
    END AS context_tree_distance,
    hi.timeline_position,
    CASE -- is applicable
      WHEN (
        -- there are listed populations
        ARRAY_UPPER(hi.listed_geo_entities_ids, 1) IS NOT NULL
        -- and the taxon has its own distribution and does not occur in any of them
        AND ARRAY_UPPER(taxon_concepts_mview.geo_entity_ids, 1) IS NOT NULL
        AND NOT hi.listed_geo_entities_ids && taxon_concepts_mview.geo_entity_ids
      ) OR (
        -- when all populations are excluded
        ARRAY_UPPER(hi.excluded_geo_entities_ids, 1) IS NOT NULL
        AND ARRAY_UPPER(taxon_concepts_mview.geo_entity_ids, 1) IS NOT NULL
        AND hi.excluded_geo_entities_ids @> taxon_concepts_mview.geo_entity_ids
      )
      THEN FALSE
      WHEN ARRAY_UPPER(hi.excluded_taxon_concept_ids, 1) IS NOT NULL
        -- if taxon or any of its ancestors is excluded from this listing
        AND hi.excluded_taxon_concept_ids && ARRAY[
          hi.affected_taxon_concept_id,
          taxon_concepts_mview.kingdom_id,
          taxon_concepts_mview.phylum_id,
          taxon_concepts_mview.class_id,
          taxon_concepts_mview.order_id,
          taxon_concepts_mview.family_id,
          taxon_concepts_mview.genus_id,
          taxon_concepts_mview.species_id
        ]
      THEN FALSE
      WHEN listing_changes_timeline.context -> hi.species_listing_id::TEXT = hi.taxon_concept_id::TEXT
        OR hi.taxon_concept_id = listing_changes_timeline.original_taxon_concept_id
        -- this line to make Moschus leucogaster happy
        OR AVALS(listing_changes_timeline.context) @> ARRAY[hi.taxon_concept_id::TEXT]
      THEN TRUE
      WHEN listing_changes_timeline.context = ''::HSTORE  --this would be the case when deleted
        AND (
          ARRAY_UPPER(hi.excluded_taxon_concept_ids, 1) IS NOT NULL
          AND NOT hi.excluded_taxon_concept_ids && ARRAY[hi.affected_taxon_concept_id]
          OR ARRAY_UPPER(hi.excluded_taxon_concept_ids, 1) IS NULL
        )
        AND hi.inclusion_taxon_concept_id IS NULL
        AND hi.change_type_name = 'ADDITION'
      THEN TRUE -- allows for re-listing
      WHEN hi.tree_distance < listing_changes_timeline.context_tree_distance
      THEN TRUE
      ELSE FALSE
    END AS is_applicable
  FROM implied_listing_changes_view hi
  JOIN listing_changes_timeline
    ON hi.designation_id = listing_changes_timeline.designation_id
    AND listing_changes_timeline.original_taxon_concept_id = hi.affected_taxon_concept_id
    AND listing_changes_timeline.timeline_position + 1 = hi.timeline_position
  JOIN change_types
    ON hi.change_type_id = change_types.id
  JOIN taxon_concepts_with_distributions_and_ancestors taxon_concepts_mview
    ON hi.affected_taxon_concept_id = taxon_concepts_mview.id
)
SELECT * FROM listing_changes_timeline;

drop table if exists tmp_all_listing_changes_timeline_matview;
drop table if exists applicable_listing_changes_timeline_dt;
drop table if exists applicable_listing_changes_timeline_mt;

create materialized view applicable_listing_changes_timeline_mv
  as select * from applicable_listing_changes_timeline_view
;

create index on applicable_listing_changes_timeline_mv (
  current_taxon_concept_id, designation_id, change_type_id, party_id, effective_at
);

create index on applicable_listing_changes_timeline_mv (
  current_taxon_concept_id, change_type_id, effective_at
);

create index on applicable_listing_changes_timeline_mv (
  species_listing_id, current_taxon_concept_id
);

create index on applicable_listing_changes_timeline_mv (
  current_taxon_concept_id, designation_id, party_id
);

-- explain analyse
-- create table tmp_all_listing_changes_timeline_dt
-- as select * from applicable_listing_changes_timeline_view;

--- 255s
--- 909344
--- cites_listing_changes_mview + eu_listing_changes_mview + cms_listing_changes_mview are 1165459
--- close but not quite

DROP VIEW IF EXISTS all_listing_changes_and_synthetics_view;
-- TODO: Why is this not applied to CMS?
CREATE OR REPLACE VIEW all_listing_changes_and_synthetics_view (
  -- want to make sure this is the same set of columns as the previous view
  "id",
  "designation_id",
  "original_taxon_concept_id",
  "current_taxon_concept_id",
  "context",
  "inclusion_taxon_concept_id",
  "party_id",
  "species_listing_id",
  "change_type_id",
  "event_id",
  "effective_at",
  "is_current",
  "context_tree_distance",
  "timeline_position",
  "is_applicable",
  -- plus a few
  "explicit_change",
  "show_in_timeline",
  "show_in_downloads",
  "show_in_history"
) AS
-- find inherited listing changes superceded by own listing changes
-- mark them as not current in context of the child and add fake deletion records
-- so that those inherited events are terminated properly on the timelines
WITH addition_change_types AS (
  SELECT *
  FROM "change_types"
  WHERE "name" = 'ADDITION'
), deletion_change_types AS (
  SELECT *
  FROM "change_types"
  WHERE "name" = 'DELETION'
), exception_change_types AS (
  SELECT *
  FROM "change_types"
  WHERE "name" = 'EXCEPTION'
), prev_lc AS (
  SELECT
    lc.id,
    lc.designation_id,
    lc.original_taxon_concept_id,
    lc.current_taxon_concept_id,
    lc.context,
    lc.inclusion_taxon_concept_id,
    lc.party_id,
    lc.species_listing_id,
    lc.change_type_id,
    lc.event_id,
    next_lc.effective_at,
    FALSE AS is_current,
    lc.context_tree_distance,
    lc.timeline_position,
    lc.is_applicable,
    (
      lc.species_listing_id != next_lc.species_listing_id
    ) AS appendix_change
  FROM addition_change_types ct
  JOIN applicable_listing_changes_timeline_mv lc
    ON lc.change_type_id = ct.id
  JOIN applicable_listing_changes_timeline_mv next_lc
    ON lc.current_taxon_concept_id = next_lc.current_taxon_concept_id
    AND lc.change_type_id = next_lc.change_type_id
    AND lc.effective_at < next_lc.effective_at
    AND next_lc.party_id IS NOT DISTINCT FROM lc.party_id
  WHERE (
      (
        -- own listing change preceded by inherited listing change
        next_lc.original_taxon_concept_id = next_lc.current_taxon_concept_id
        AND lc.original_taxon_concept_id != lc.current_taxon_concept_id
      ) OR (
        -- own listing change preceded by own listing change if it is a not current inclusion
        next_lc.original_taxon_concept_id = next_lc.current_taxon_concept_id
        AND lc.original_taxon_concept_id = lc.current_taxon_concept_id
        AND lc.inclusion_taxon_concept_id IS NOT NULL
        AND NOT lc.is_current
      ) OR (
        -- inherited listing change preceded by inherited listing change
        next_lc.original_taxon_concept_id != next_lc.current_taxon_concept_id
        AND lc.original_taxon_concept_id != lc.current_taxon_concept_id
      ) OR (
        -- inherited listing change preceded by own listing change if it is a not current inclusion
        -- in the same taxon concept as the current listing change
        next_lc.original_taxon_concept_id != next_lc.current_taxon_concept_id
        AND lc.original_taxon_concept_id = lc.current_taxon_concept_id
        AND lc.inclusion_taxon_concept_id IS NOT NULL
        AND (
          lc.inclusion_taxon_concept_id = next_lc.original_taxon_concept_id
          OR NOT lc.is_current
        )
      )
    )
), fake_deletions AS (
  -- note: this generates records without an id
  -- this is ok for the timelines, and those records are not used elsewhere
  -- ids in this view are not unique anyway, since any id
  -- from listing changes can occur multiple times
  SELECT
    -- TODO: test if multiple appendix changes work
    DISTINCT ON (
      lc.original_taxon_concept_id,
      lc.current_taxon_concept_id,
      lc.designation_id,
      lc.species_listing_id,
      lc.party_id
    )
    0 - lc.id                    AS id,
    lc.designation_id            AS designation_id,
    lc.original_taxon_concept_id AS original_taxon_concept_id,
    lc.current_taxon_concept_id  AS current_taxon_concept_id,
    ''::hstore                   AS context,
    NULL::INT                    AS inclusion_taxon_concept_id,
    lc.party_id                  AS party_id,
    lc.species_listing_id        AS species_listing_id,
    ct.id                        AS change_type_id,
    lc.event_id                  AS event_id,
    lc.effective_at              AS effective_at,
    TRUE                         AS is_current,
    lc.context_tree_distance     AS context_tree_distance,
    lc.timeline_position         AS timeline_position,
    TRUE                         AS is_applicable,
    FALSE                        AS explicit_change,
    TRUE                         AS show_in_timeline,
    FALSE                        AS show_in_downloads,
    FALSE                        AS show_in_history
  FROM prev_lc lc
  JOIN deletion_change_types ct
    ON ct.designation_id = lc.designation_id
  WHERE appendix_change
)
-- SELECT
--   lc.id,
--   lc.designation_id,
--   lc.original_taxon_concept_id,
--   lc.current_taxon_concept_id,
--   lc.context,
--   lc.inclusion_taxon_concept_id,
--   lc.party_id,
--   lc.species_listing_id,
--   lc.change_type_id,
--   lc.event_id,
--   lc.effective_at,
--   CASE
--     WHEN terminated_lc.id IS NOT NULL THEN TRUE
--     ELSE lc.is_current
--   END AS is_current,
--   lc.context_tree_distance,
--   lc.timeline_position,
--   lc.is_applicable,
--   TRUE                     AS explicit_change,
--   xct.id IS NULL           AS show_in_timeline,
--   xct.id IS NULL           AS show_in_history,
--   xct.id IS NULL           AS show_in_downloads
-- FROM applicable_listing_changes_timeline_mv lc
-- -- if the row exists in prev_lc then it has been superseded
-- LEFT JOIN prev_lc terminated_lc
--   ON terminated_lc.id = lc.id
--   AND terminated_lc.current_taxon_concept_id = lc.current_taxon_concept_id
-- LEFT JOIN exception_change_types xct
--   ON lc.change_type_id = xct.id
-- UNION ALL
SELECT
  id,
  designation_id,
  original_taxon_concept_id,
  current_taxon_concept_id,
  context,
  inclusion_taxon_concept_id,
  party_id,
  species_listing_id,
  change_type_id,
  event_id,
  effective_at,
  is_current,
  context_tree_distance,
  timeline_position,
  is_applicable,
  explicit_change,
  show_in_timeline,
  show_in_history,
  show_in_downloads
FROM fake_deletions
;


drop table if exists synth_listing_changes_timeline_dt;
explain analyse
create table synth_listing_changes_timeline_dt
as select * from all_listing_changes_and_synthetics_view where designation_id = 1;


--  CTE Scan on fake_deletions  (cost=2358.58..2358.61 rows=1 width=86) (actual time=359431.642..359435.274 rows=28 loops=1)
--    Filter: (designation_id = 1)
--    Rows Removed by Filter: 18
--    CTE addition_change_types
--      ->  Seq Scan on change_types  (cost=0.00..1.19 rows=1 width=636) (actual time=0.007..0.011 rows=3 loops=1)
--            Filter: ((name)::text = 'ADDITION'::text)
--            Rows Removed by Filter: 12
--    CTE deletion_change_types
--      ->  Seq Scan on change_types change_types_1  (cost=0.00..1.19 rows=1 width=636) (actual time=0.012..0.014 rows=3 loops=1)
--            Filter: ((name)::text = 'DELETION'::text)
--            Rows Removed by Filter: 12
--    CTE prev_lc
--      ->  Nested Loop  (cost=0.45..2356.13 rows=1 width=83) (actual time=0.143..162253.135 rows=335815170 loops=1)
--            ->  Hash Join  (cost=0.03..2153.73 rows=366 width=86) (actual time=0.029..150.562 rows=63307 loops=1)
--                  Hash Cond: (lc.change_type_id = ct.id)
--                  ->  Seq Scan on applicable_listing_changes_timeline_mv lc  (cost=0.00..1875.39 rows=73239 width=82) (actual time=0.007..31.230 rows=73239 loops=1)
--                  ->  Hash  (cost=0.02..0.02 rows=1 width=4) (actual time=0.014..0.015 rows=3 loops=1)
--                        Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                        ->  CTE Scan on addition_change_types ct  (cost=0.00..0.02 rows=1 width=4) (actual time=0.008..0.012 rows=3 loops=1)
--            ->  Index Scan using applicable_listing_changes_ti_current_taxon_concept_id_chan_idx on applicable_listing_changes_timeline_mv next_lc  (cost=0.42..0.54 rows=1 width=24) (actual time=0.016..1.573 rows=5305 loops=63307)
--                  Index Cond: ((current_taxon_concept_id = lc.current_taxon_concept_id) AND (change_type_id = lc.change_type_id) AND (lc.effective_at < effective_at))
--                  Filter: ((NOT (party_id IS DISTINCT FROM lc.party_id)) AND (((original_taxon_concept_id = current_taxon_concept_id) AND (lc.original_taxon_concept_id <> lc.current_taxon_concept_id)) OR ((original_taxon_concept_id = current_taxon_concept_id) AND (lc.original_taxon_concept_id = lc.current_taxon_concept_id) AND (lc.inclusion_taxon_concept_id IS NOT NULL) AND (NOT lc.is_current)) OR ((original_taxon_concept_id <> current_taxon_concept_id) AND (lc.original_taxon_concept_id <> lc.current_taxon_concept_id)) OR ((original_taxon_concept_id <> current_taxon_concept_id) AND (lc.original_taxon_concept_id = lc.current_taxon_concept_id) AND (lc.inclusion_taxon_concept_id IS NOT NULL) AND ((lc.inclusion_taxon_concept_id = original_taxon_concept_id) OR (NOT lc.is_current)))))
--                  Rows Removed by Filter: 44
--    CTE fake_deletions
--      ->  Unique  (cost=0.07..0.08 rows=1 width=86) (actual time=359431.636..359435.238 rows=46 loops=1)
--            ->  Sort  (cost=0.07..0.07 rows=1 width=86) (actual time=359431.634..359432.354 rows=13415 loops=1)
--                  Sort Key: lc_1.original_taxon_concept_id, lc_1.current_taxon_concept_id, lc_1.designation_id, lc_1.species_listing_id, lc_1.party_id
--                  Sort Method: quicksort  Memory: 2271kB
--                  ->  Nested Loop  (cost=0.00..0.06 rows=1 width=86) (actual time=11359.141..359426.368 rows=13415 loops=1)
--                        Join Filter: (lc_1.designation_id = ct_1.designation_id)
--                        Rows Removed by Join Filter: 26830
--                        ->  CTE Scan on prev_lc lc_1  (cost=0.00..0.02 rows=1 width=40) (actual time=11359.123..359415.743 rows=13415 loops=1)
--                              Filter: appendix_change
--                              Rows Removed by Filter: 335801755
--                        ->  CTE Scan on deletion_change_types ct_1  (cost=0.00..0.02 rows=1 width=8) (actual time=0.000..0.000 rows=3 loops=13415)
--  Planning time: 1.459 ms
--  Execution time: 360161.079 ms
-- (37 rows)