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
    -- It turns out that some non-A names have ancestries
    -- AND "name_status" = 'A'
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
      row_number() OVER() AS "rank_depth"
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
UNION ALL
  SELECT
    "ta"."taxonomy_id",
    "ta"."id",
    "ta"."rank_id",
    "ta"."ancestor_ids",
    '{}'                    AS "path_ids",
    "ta"."id"               AS "ancestor_id",
    "ta"."rank_id"          AS "ancestor_rank_id",
    "descendant_rank_depth" AS "ancestor_rank_depth",
    "descendant_rank_depth" AS "rank_depth",
    0                       AS "rank_distance"
  FROM "taxon_ancestors" ta
  JOIN "rank_distances" rd
    ON "rd"."descendant_rank_id" = "ta"."rank_id"
    AND "rd"."ancestor_rank_id"  = "ta"."rank_id"

;

create materialized view taxon_ancestors_mv
  as select * from taxon_ancestors_dv
;

create index on taxon_ancestors_mv (
  id, ancestor_id
);

create index on taxon_ancestors_mv (
  id, rank_distance
);

create index on taxon_ancestors_mv (
  id, ancestor_rank_depth
);

create index on taxon_ancestors_mv (
  id, ancestor_rank_id
);

DROP VIEW IF EXISTS change_types_view CASCADE;
CREATE OR REPLACE VIEW change_types_view AS
SELECT
  ct.*,
  CASE
    WHEN ct.name = 'RESERVATION_WITHDRAWAL' THEN 1
    WHEN ct.name = 'DELETION' THEN 2
    WHEN ct.name = 'EXCEPTION' THEN 3
    WHEN ct.name = 'ADDITION' THEN 4
    WHEN ct.name = 'RESERVATION' THEN 5
  END change_type_rank,
  CASE
    WHEN ct.name IN ('ADDITION', 'DELETION', 'EXCEPTION') THEN 1
    ELSE 2
  END change_type_group_id -- A/D/X, R/W
FROM change_types ct;

DROP VIEW IF EXISTS implied_listing_changes_view CASCADE;
CREATE OR REPLACE VIEW implied_listing_changes_view AS
-- affected_taxon_concept is a taxon concept that is affected by this listing
-- change, even though it might not have an explicit connection to it
-- (i.e. it is an ancestor's listing change).
WITH designations_and_intervals AS (
  SELECT
    designations.id          AS designation_id,
    designations.name        AS designation_name,
    designations.taxonomy_id AS taxonomy_id,
    intervals.start_date     AS interval_start_date,
    intervals.end_date       AS interval_end_date,
    intervals.events_ids     AS interval_events_ids
  FROM designations
  LEFT JOIN eu_regulations_applicability_view intervals
    ON designations.name = 'EU'
), listing_changes_with_exclusions AS (
  -- the purpose of this CTE is to aggregate excluded taxon concept ids
  SELECT
    lc.id,
    ct.designation_id,
    designations_and_intervals.interval_events_ids,
    lc.taxon_concept_id,
    lc.species_listing_id,
    lc.inclusion_taxon_concept_id,
    ct.id               AS change_type_id,
    ct.change_type_rank AS change_type_rank,
    ct.name             AS change_type_name,
    lc.event_id,
    -- A bug exists where EXCLUSIONS have `effective_at='2012-09-21 07:32:20'`,
    -- instead of that of the parent.
    COALESCE(included_lc.effective_at, lc.effective_at)::DATE AS effective_at,
    lc.is_current,
    ARRAY_AGG_NOTNULL(taxonomic_exclusions.taxon_concept_id) AS excluded_taxon_concept_ids
  FROM listing_changes lc
  LEFT JOIN listing_changes taxonomic_exclusions
    ON lc.id = taxonomic_exclusions.parent_id
    AND lc.taxon_concept_id != taxonomic_exclusions.taxon_concept_id
  JOIN change_types_view ct ON ct.id = lc.change_type_id
  JOIN designations_and_intervals
    ON designations_and_intervals.designation_id = ct.designation_id
    AND (
      designations_and_intervals IS NULL
      OR ARRAY_UPPER(designations_and_intervals.interval_events_ids, 1) IS NULL
      OR lc.event_id = ANY(designations_and_intervals.interval_events_ids)
    )
  LEFT JOIN listing_changes included_lc
    ON lc.parent_id = included_lc.id
  GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
), aggregate_lc AS (
  -- the purpose of this CTE is to aggregate listed and excluded populations
  -- All rows in this table will go into implied_listing_changes_view
  SELECT
    lc.id,
    lc.designation_id,
    lc.interval_events_ids,
    lc.taxon_concept_id,
    lc.species_listing_id,
    lc.inclusion_taxon_concept_id,
    lc.change_type_id,
    lc.change_type_name,
    lc.change_type_rank,
    lc.event_id,
    lc.effective_at,
    lc.is_current,
    lc.excluded_taxon_concept_ids,
    party_distribution.geo_entity_id AS party_id,
    ARRAY_AGG_NOTNULL(listing_distributions.geo_entity_id) AS listed_geo_entities_ids,
    ARRAY_AGG_NOTNULL(excluded_distributions.geo_entity_id) AS excluded_geo_entities_ids
  FROM listing_changes_with_exclusions lc
  LEFT JOIN listing_distributions
    ON lc.id = listing_distributions.listing_change_id
    AND NOT listing_distributions.is_party
  LEFT JOIN listing_distributions party_distribution
    ON lc.id = party_distribution.listing_change_id
    AND party_distribution.is_party
  LEFT JOIN listing_changes population_exclusions
    ON lc.id = population_exclusions.parent_id
    AND lc.taxon_concept_id = population_exclusions.taxon_concept_id
  LEFT JOIN listing_distributions excluded_distributions
    ON population_exclusions.id = excluded_distributions.listing_change_id
    AND NOT excluded_distributions.is_party
  GROUP BY
    lc.id,
    lc.designation_id,
    lc.interval_events_ids,
    lc.taxon_concept_id,
    lc.species_listing_id,
    lc.inclusion_taxon_concept_id,
    lc.change_type_id,
    lc.change_type_name,
    lc.change_type_rank,
    lc.event_id,
    lc.effective_at,
    lc.is_current,
    party_distribution.geo_entity_id,
    lc.excluded_taxon_concept_ids
), addition_groups AS (
  SELECT
    DISTINCT ON (
      lc.designation_id,
      lc.interval_events_ids,
      lc.taxon_concept_id,
      lc.party_id,
      lc.effective_at::DATE
    )
    lc.designation_id,
    lc.interval_events_ids,
    lc.taxon_concept_id,
    lc.party_id,
    lc.effective_at::DATE AS effective_at,
    hstore(
      array_agg(ARRAY[species_listing_id, lc.id]::TEXT[]) FILTER (
        WHERE lc.change_type_name = 'ADDITION'
      ) OVER (
        PARTITION BY
          lc.taxon_concept_id,
          lc.designation_id,
          lc.interval_events_ids,
          lc.party_id,
          lc.effective_at::DATE
        ORDER BY
          species_listing_id
      )
    ) AS additions_by_listing_id,
    hstore(
      -- todo: multiple listing changes per appendix is possible
      array_agg(ARRAY[species_listing_id, lc.id]::TEXT[]) FILTER (
        WHERE lc.change_type_name = 'DELETION'
      ) OVER (
        PARTITION BY
          lc.taxon_concept_id,
          lc.designation_id,
          lc.interval_events_ids,
          lc.party_id,
          lc.effective_at::DATE
        ORDER BY
          species_listing_id
      )
    ) AS deletions_by_listing_id,
    CASE WHEN lc.change_type_name = 'ADDITION'
      THEN dense_rank() OVER (
        PARTITION BY
          lc.taxon_concept_id,
          lc.designation_id,
          lc.interval_events_ids,
          lc.party_id,
          lc.change_type_name
        ORDER BY
          lc.effective_at::DATE
      )::INT
    END AS addition_group_rank,
    CASE WHEN lc.change_type_name IN ('ADDITION', 'DELETION')
      THEN dense_rank() OVER (
        PARTITION BY
          lc.taxon_concept_id,
          lc.designation_id,
          lc.interval_events_ids,
          lc.party_id
        ORDER BY
          lc.effective_at::DATE
      )::INT
    END AS add_del_group_rank
  FROM aggregate_lc lc
  WHERE lc.change_type_name IN ('ADDITION', 'DELETION')
  ORDER BY
    lc.designation_id,
    lc.interval_events_ids,
    lc.taxon_concept_id,
    lc.party_id,
    lc.effective_at::DATE
), synthetic_deletions_needed AS (
  -- TODO: make this recursive and stateful as we cannot rely on additions.
  -- OR create synthetic additions instead?
  SELECT DISTINCT
    ag.designation_id,
    ag.interval_events_ids,
    ag.taxon_concept_id,
    ag.party_id,
    ag.addition_group_rank,
    ag.effective_at,
    unnest(akeys(deletions_by_listing_id))::BIGINT AS species_listing_id,
    unnest(avals(deletions_by_listing_id))::BIGINT AS deleted_listing_change_id
  FROM (
    SELECT
      ag.designation_id,
      ag.interval_events_ids,
      ag.taxon_concept_id,
      ag.addition_group_rank,
      ag.party_id,
      ag.effective_at::DATE AS effective_at,
      (
        prev_ag.additions_by_listing_id
      ) - COALESCE(
        akeys(ag.deletions_by_listing_id), '{}'::text[]
      ) - COALESCE(
        array_agg(
          (SELECT key FROM each(dg.deletions_by_listing_id))
        ) OVER (
          PARTITION BY
            ag.designation_id,
            ag.interval_events_ids,
            ag.taxon_concept_id,
            ag.party_id,
            ag.addition_group_rank
        ),
        '{}'::text[]
      ) AS deletions_by_listing_id
    FROM addition_groups ag
    JOIN addition_groups prev_ag
      ON ag.designation_id = prev_ag.designation_id
      AND ag.interval_events_ids IS NOT DISTINCT FROM prev_ag.interval_events_ids
      AND ag.taxon_concept_id = prev_ag.taxon_concept_id
      AND ag.party_id IS NOT DISTINCT FROM prev_ag.party_id
      AND ag.addition_group_rank = prev_ag.addition_group_rank + 1
    LEFT JOIN addition_groups dg
      ON ag.designation_id = dg.designation_id
      AND ag.interval_events_ids IS NOT DISTINCT FROM dg.interval_events_ids
      AND ag.taxon_concept_id = dg.taxon_concept_id
      AND ag.party_id IS NOT DISTINCT FROM dg.party_id
      AND ag.add_del_group_rank > dg.add_del_group_rank
      AND prev_ag.add_del_group_rank < dg.add_del_group_rank
  ) AS ag
)
SELECT
  0 - ag.deleted_listing_change_id AS id,
  ag.designation_id,
  ag.interval_events_ids,
  ag.taxon_concept_id,
  ag.species_listing_id,
  NULL                AS inclusion_taxon_concept_id,
  ct.id               AS change_type_id,
  ct.name             AS change_type_name,
  ct.change_type_rank AS change_type_rank,
  NULL                AS event_id,
  ag.effective_at     AS effective_at,
  FALSE               AS is_current,
  '{}'                AS excluded_taxon_concept_ids,
  ag.party_id         AS party_id,
  '{}'                AS listed_geo_entities_ids,
  '{}'                AS excluded_geo_entities_ids
FROM synthetic_deletions_needed ag
JOIN change_types_view ct
  ON ct.designation_id = ag.designation_id
  AND ct.name = 'DELETION'
UNION ALL
SELECT * FROM aggregate_lc;

DROP VIEW IF EXISTS inherited_listing_changes_view CASCADE;
CREATE OR REPLACE VIEW inherited_listing_changes_view AS
SELECT DISTINCT
  tc.id AS taxon_concept_id,
  lc.id AS listing_change_id,
  lc.designation_id,
  lc.interval_events_ids,
  lc.species_listing_id,
  lc.inclusion_taxon_concept_id,
  lc.taxon_concept_id AS original_taxon_concept_id,
  -- Make the tree distance reflect distance from inclusion
  -- TODO TEST Rhinopittecus roxellana
  COALESCE(itc.rank_distance, tc.rank_distance) rank_distance,
  lc.change_type_id,
  lc.change_type_name,
  lc.change_type_rank,
  lc.event_id,
  lc.effective_at,
  lc.is_current,
  lc.excluded_taxon_concept_ids,
  lc.party_id,
  lc.listed_geo_entities_ids,
  lc.excluded_geo_entities_ids,
  -- The following dense_rank() call will assign a unique id to each combination
  -- of affected taxon concept, designation, and party.
  dense_rank() OVER (
    ORDER BY
      lc.taxon_concept_id,
      lc.designation_id,
      lc.interval_events_ids,
      lc.party_id
  )::BIGINT taxon_party_timeline_id,
  -- The following dense_rank() call will assign chronological order to listing
  -- changes in scope of the affected taxon concept and a particular
  -- designation/party combination
  dense_rank() OVER (
    PARTITION BY
      lc.taxon_concept_id,
      lc.designation_id,
      lc.interval_events_ids,
      lc.party_id
    ORDER BY
      lc.effective_at,
      lc.change_type_rank,
      tc.rank_distance DESC
  )::INT AS timeline_position
FROM implied_listing_changes_view lc
JOIN taxon_ancestors_mv tc
  ON lc.taxon_concept_id = tc.ancestor_id
LEFT JOIN taxon_ancestors_mv itc
  ON lc.inclusion_taxon_concept_id = itc.ancestor_id
  AND lc.taxon_concept_id = itc.id
;

DROP VIEW IF EXISTS taxon_concepts_with_distributions_and_ancestors CASCADE;
CREATE OR REPLACE VIEW taxon_concepts_with_distributions_and_ancestors AS
SELECT
  tc.*,
  AVALS(ancestor_fields)::INTEGER[] || tc.id  AS ancestor_ids,
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
    ) AS ancestor_fields,
    hstore(
      array_agg(ARRAY[rank_distance::text, ancestor_id::text])
    ) AS ancestor_id_by_distance
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


DROP VIEW IF EXISTS applicable_implied_taxon_listing_changes_view CASCADE;
CREATE OR REPLACE VIEW applicable_implied_taxon_listing_changes_view AS
SELECT
  lc.*,
  (
    -- there are listed populations
    ARRAY_UPPER(listed_geo_entities_ids, 1) IS NOT NULL
    -- and the taxon has its own distribution and does not occur in any of them
    AND ARRAY_UPPER(tc.geo_entity_ids, 1) IS NOT NULL
    AND NOT listed_geo_entities_ids && tc.geo_entity_ids
  ) OR (
    -- when all populations are excluded
    ARRAY_UPPER(excluded_geo_entities_ids, 1) IS NOT NULL
    AND ARRAY_UPPER(tc.geo_entity_ids, 1) IS NOT NULL
    AND excluded_geo_entities_ids @> tc.geo_entity_ids
  ) AS is_geographically_excluded,
  (
    ARRAY_UPPER(excluded_taxon_concept_ids, 1) IS NOT NULL
    -- if taxon or any of its ancestors is excluded from this listing
    AND excluded_taxon_concept_ids && tc.ancestor_ids
  ) AS is_taxonomically_excluded
FROM inherited_listing_changes_view lc
JOIN taxon_concepts_with_distributions_and_ancestors tc
  ON lc.taxon_concept_id = tc.id;


-- A timeline is identified by:
--
-- * `taxon_concept_id`
-- * `designation_id`
-- * `interval_events_ids`
-- * `party_id` (important for e.g. Agapornis fischeri)
--
-- A timeline can have one or more snapshots.
--
-- * `taxon_concept_id`
-- * `listing_change_id`
-- * (`designation_id` is strictly redundant, dependent on `listing_change_id`)
-- * `interval_events_ids`
-- * `party_id`
-- * `timeline_position`


DROP TABLE IF EXISTS tmp_all_listing_changes_timeline_matview;
DROP TABLE IF EXISTS applicable_listing_changes_timeline_dt;
DROP TABLE IF EXISTS applicable_listing_changes_timeline_mt;

CREATE MATERIALIZED VIEW applicable_listing_changes_timeline_mv AS
  SELECT * FROM applicable_implied_taxon_listing_changes_view;

CREATE INDEX ON applicable_listing_changes_timeline_mv (
  taxon_concept_id, designation_id, change_type_id, party_id, effective_at
);

CREATE INDEX ON applicable_listing_changes_timeline_mv (
  taxon_party_timeline_id
);

CREATE INDEX ON applicable_listing_changes_timeline_mv (
  taxon_concept_id, change_type_id, effective_at, original_taxon_concept_id
);
CREATE INDEX ON applicable_listing_changes_timeline_mv (
  change_type_id, taxon_concept_id, original_taxon_concept_id
);

CREATE INDEX ON applicable_listing_changes_timeline_mv (
  species_listing_id, taxon_concept_id
);

CREATE INDEX ON applicable_listing_changes_timeline_mv (
  taxon_concept_id, designation_id, party_id
);

CREATE INDEX ON applicable_listing_changes_timeline_mv (
  original_taxon_concept_id,
  taxon_concept_id,
  designation_id,
  species_listing_id,
  party_id
);

CREATE INDEX ON applicable_listing_changes_timeline_mv (
  taxon_concept_id, effective_at, listing_change_id
);

CREATE INDEX ON applicable_listing_changes_timeline_mv (
  listing_change_id, taxon_concept_id
);

CREATE INDEX ON applicable_listing_changes_timeline_mv (
  taxon_party_timeline_id, change_type_name
);

-- target #- path
-- jsonb_insert(target, path, newval)
CREATE OR REPLACE FUNCTION jsonb_object_merge(

) RETURNS jsonb LANGUAGE SQL AS
$jsonb_object_merge$
$jsonb_object_merge$

CREATE OR REPLACE FUNCTION merge_listing_state_changes(
  initial_state jsonb,
  state_change jsonb
) RETURNS jsonb LANGUAGE SQL AS
$merge_listing_state_changes$
  SELECT
    'ADDITION', (
      SELECT jsonb_object_agg(
      FROM jsonb_each(initial_state->'ADDITION')
    )
    'RESERVATION', initial_state->'RESERVATION'

$merge_listing_state_changes$

WITH listing_change_groups AS (
  SELECT
    DISTINCT ON (
      lc.taxon_party_timeline_id,
      lc.effective_at,
      lc.change_type_name IN ('ADDITION', 'DELETION', 'EXCLUSION')
    )
    lc.taxon_party_timeline_id,
    lc.designation_id,
    lc.interval_events_ids,
    lc.party_id,
    lc.taxon_concept_id,
    lc.effective_at,
    lc.change_type_name IN ('ADDITION', 'DELETION', 'EXCLUSION') AS is_adx,
    -- Build jsonbs of the form:
    -- [rank_distance][species_listing_id][listing_change_id]: TRUE
    array_agg(
      ARRAY[lc.change_type_name, lc.rank_distance, lc.species_listing_id, lc.listing_change_id]::TEXT[]
    ) OVER (
      PARTITION BY
        lc.taxon_party_timeline_id,
        lc.effective_at,
        lc.change_type_name IN ('ADDITION', 'DELETION', 'EXCLUSION')
    ) listing_changes,
    dense_rank() OVER (
      PARTITION BY
        lc.taxon_party_timeline_id,
        lc.change_type_name IN ('ADDITION', 'DELETION', 'EXCLUSION')
      ORDER BY
        lc.effective_at
    )::INT AS change_group_rank
  FROM applicable_listing_changes_timeline_mv lc
  ORDER BY
    lc.taxon_party_timeline_id,
    lc.effective_at,
    lc.change_type_name IN ('ADDITION', 'DELETION', 'EXCLUSION')
), listing_change_groups_with_keyed_info as (
  SELECT *, (
  CASE
  WHEN listing_changes IS NULL OR array_length(listing_changes, 1) < 1
  THEN NULL
  ELSE (
    SELECT jsonb_object_agg(
      d.change_type_name,
      d.by_rank_distance
    ) by_change_type_name
    FROM (
      SELECT
        d.change_type_name,
        jsonb_object_agg(
          d.rank_distance::text,
          d.by_species_listing_id
        ) OVER (
          PARTITION BY d.change_type_name
        ) by_rank_distance
      FROM (
        SELECT
          d.change_type_name,
          d.rank_distance,
          jsonb_object_agg(
            d.species_listing_id::text, by_listing_change_id
          ) OVER (
            PARTITION BY
              d.change_type_name,
              d.rank_distance
          ) AS by_species_listing_id
        FROM (
          SELECT
            d.change_type_name,
            d.rank_distance,
            d.species_listing_id,
            jsonb_object_agg(
              d.listing_change_id::text, true
            ) OVER (
              PARTITION BY
                d.change_type_name,
                d.rank_distance,
                d.species_listing_id
            ) AS by_listing_change_id
          FROM (
            SELECT
              unnest((listing_changes::TEXT[][])[1:][1:1]),
              unnest((listing_changes::TEXT[][])[1:][2:2]),
              unnest((listing_changes::TEXT[][])[1:][3:3]),
              unnest((listing_changes::TEXT[][])[1:][4:4])
          ) d (change_type_name, rank_distance, species_listing_id, listing_change_id)
        ) d
      ) d
    ) d
  )
  END
) listing_state_changes
 FROM listing_change_groups
) RECURSIVE stateful_listing_change_groups AS (
  SELECT
    SELECT
      lcg.taxon_party_timeline_id,
      lcg.designation_id,
      lcg.interval_events_ids,
      lcg.party_id,
      lcg.taxon_concept_id,
      lcg.effective_at,
      lcg.is_adx,
      lcg.listing_state_changes,
      lcg.listing_state_changes AS listing_state
    FROM listing_change_groups_with_keyed_info lcg
    WHERE lcg.change_group_rank = 1
  UNION
    SELECT
      lcg.taxon_party_timeline_id,
      lcg.designation_id,
      lcg.interval_events_ids,
      lcg.party_id,
      lcg.taxon_concept_id,
      lcg.effective_at,
      lcg.is_adx,
      lcg.listing_state_changes,
      merge_listing_state_changes(
        lcg.listing_state,
        lcg.listing_state_changes
      ) AS listing_state
    FROM listing_change_groups_with_keyed_info lcg
    JOIN stateful_listing_change_groups prev_lcg
      ON lcg.taxon_party_timeline_id = prev_lcg.taxon_party_timeline_id
      AND lcg.change_group_rank = prev_lcg.change_group_rank + 1
)
select * from foo where taxon_concept_id = 6353 and designation_id = 1;

select * from applicable_listing_changes_timeline_mv lc where taxon_concept_id = 6353 and designation_id = 1;
