CREATE OR REPLACE FUNCTION higher_or_equal_ranks_names(in_rank_name VARCHAR(255))
  RETURNS TEXT[]
  LANGUAGE sql IMMUTABLE
  AS $$
    WITH ranks_in_order(row_no, rank_name) AS (
      SELECT ROW_NUMBER() OVER(), *
      FROM UNNEST(ARRAY[
      'VARIETY', 'SUBSPECIES', 'SPECIES', 'GENUS', 'SUBFAMILY',
      'FAMILY', 'ORDER', 'CLASS', 'PHYLUM', 'KINGDOM'
      ])
    )
    SELECT ARRAY_AGG(rank_name) FROM ranks_in_order
    WHERE row_no >= (SELECT row_no FROM ranks_in_order WHERE rank_name = $1);
  $$;

CREATE OR REPLACE FUNCTION rebuild_all_listing_changes_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    PERFORM redefine_all_listing_changes_view();
    RAISE NOTICE 'Creating all listing changes materialized view';
    CREATE TABLE all_listing_changes_mview AS
    SELECT *,
    false as dirty,
    null::timestamp with time zone as expiry
    FROM all_listing_changes_view;

    CREATE INDEX ON all_listing_changes_mview (designation_id, timeline_position, affected_taxon_concept_id);
    CREATE INDEX ON all_listing_changes_mview (affected_taxon_concept_id, inclusion_taxon_concept_id);
    CREATE INDEX ON all_listing_changes_mview (id, affected_taxon_concept_id);

    RAISE NOTICE 'Fixing inclusion tree distance in all listing changes materialized view';
    -- make the tree distance reflect distance from inclusion (Rhinopittecus roxellana)
    UPDATE all_listing_changes_mview
    SET tree_distance = taxon_concept_and_ancestors.tree_distance
    FROM all_listing_changes_mview alc
    JOIN taxon_concept_and_ancestors
    ON alc.inclusion_taxon_concept_id = taxon_concept_and_ancestors.ancestor_taxon_concept_id
    AND alc.affected_taxon_concept_id = taxon_concept_and_ancestors.taxon_concept_id
    WHERE alc.id = all_listing_changes_mview.id
    AND alc.affected_taxon_concept_id = all_listing_changes_mview.affected_taxon_concept_id;
  END;
  $$;

CREATE OR REPLACE FUNCTION redefine_all_listing_changes_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    PERFORM redefine_all_listing_changes_view();
    RAISE NOTICE 'Redefining all listing changes materialized view';
    CREATE TABLE all_listing_changes_mview AS
    SELECT *,
    false as dirty,
    null::timestamp with time zone as expiry
    FROM all_listing_changes_view LIMIT 0;
  END;
  $$;

CREATE OR REPLACE FUNCTION redefine_all_listing_changes_view() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    RAISE NOTICE 'Dropping all listing changes materialized view';
    DROP table IF EXISTS all_listing_changes_mview CASCADE;

    RAISE NOTICE 'Dropping all listing changes view';
    DROP VIEW IF EXISTS all_listing_changes_view;

    RAISE NOTICE 'Creating taxon_concept_and_ancestors tmp table';
    DROP TABLE IF EXISTS taxon_concept_and_ancestors;
    CREATE TEMP TABLE taxon_concept_and_ancestors AS
    -- This query took like half a day to get right, so maybe it deserves a comment.
    -- It uses a sql procedure (ary_higher_or_equal_ranks_names) to return all ranks above
    -- the current taxon concept and then from those ranks get at actual ancestor ids.
    -- The reason for doing it that way is to make use of ancestor data which we already store
    -- for every taxon concept in columns named 'name_of_rank_id'.
    -- We also want to know the tree distance between the current taxon concept and any
    -- of its ancestors.
    -- So we call the higher_or_equal_ranks_names procedure for every taxon concept,
    -- and the only way to parametrise it correctly is to call it in the select clause.
    -- Because it returns an array of ranks, and what we want is a set of (taxon concept, ancestor, distance),
    -- we then go through the UNNEST thing in order to arrive at separate rows per ancestor.
    -- In order to know the distance it is enough to know the index of the ancestor in the originally
    -- returned array, because it is already sorted accordingly. That's what GENERATE_SUBSCRIPTS does.
    -- Quite surprisingly, this worked.
    SELECT id AS taxon_concept_id,
    (data->(LOWER(UNNEST(higher_or_equal_ranks_names(data->'rank_name'))) || '_id'))::INT AS ancestor_taxon_concept_id,
    GENERATE_SUBSCRIPTS(higher_or_equal_ranks_names(data->'rank_name'), 1) - 1 AS tree_distance
    FROM taxon_concepts;

    CREATE INDEX ON taxon_concept_and_ancestors (ancestor_taxon_concept_id);

    RAISE NOTICE 'Creating listing_changes_with_distributions tmp table';
    DROP TABLE IF EXISTS listing_changes_with_distributions;
    CREATE TEMP table listing_changes_with_distributions AS
    -- affected_taxon_concept -- is a taxon concept that is affected by this listing change,
    -- even though it might not have an explicit connection to it
    -- (i.e. it's an ancestor's listing change)
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
        listing_changes.effective_at::DATE,
        ARRAY_AGG_NOTNULL(taxonomic_exceptions.taxon_concept_id) AS excluded_taxon_concept_ids
      FROM listing_changes
      LEFT JOIN listing_changes taxonomic_exceptions
      ON listing_changes.id = taxonomic_exceptions.parent_id 
      AND listing_changes.taxon_concept_id != taxonomic_exceptions.taxon_concept_id
      JOIN change_types ON change_types.id = listing_changes.change_type_id
      GROUP BY
        listing_changes.id,
        change_types.designation_id,
        change_types.name,
        listing_changes.taxon_concept_id,
        listing_changes.species_listing_id,
        listing_changes.change_type_id,
        listing_changes.inclusion_taxon_concept_id,
        listing_changes.effective_at::DATE
    )
      -- the purpose of this CTE is to aggregate listed and excluded populations
      SELECT lc.id, 
        lc.designation_id,
        lc.change_type_name,
        lc.taxon_concept_id,
        lc.species_listing_id,
        lc.change_type_id,
        lc.inclusion_taxon_concept_id,
        lc.effective_at,
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
        lc.effective_at,
        party_distribution.geo_entity_id,
        lc.excluded_taxon_concept_ids;
  
    CREATE INDEX ON listing_changes_with_distributions (taxon_concept_id);

    RAISE NOTICE 'Creating all listing changes view';
    CREATE VIEW all_listing_changes_view AS
    SELECT
        listing_changes.*,
        taxon_concept_and_ancestors.taxon_concept_id AS affected_taxon_concept_id,
        taxon_concept_and_ancestors.tree_distance,
        -- the following ROW_NUMBER call will assign chronological order to listing changes
        -- in scope of the affected taxon concept and a particular designation
        ROW_NUMBER() OVER (
            PARTITION BY taxon_concept_and_ancestors.taxon_concept_id, designation_id
            ORDER BY effective_at,
            CASE
              WHEN change_type_name = 'DELETION' THEN 0
              WHEN change_type_name = 'ADDITION' THEN 1
              WHEN change_type_name = 'RESERVATION_WITHDRAWAL' THEN 2
              WHEN change_type_name = 'RESERVATION' THEN 3
              WHEN change_type_name = 'EXCEPTION' THEN 4
            END,
            tree_distance
        )::INT AS timeline_position
    FROM listing_changes_with_distributions listing_changes
    JOIN taxon_concept_and_ancestors taxon_concept_and_ancestors
    ON listing_changes.taxon_concept_id = taxon_concept_and_ancestors.ancestor_taxon_concept_id;

  END;
  $$;

--this line is here so that the following procedure, which depends on this materialized view, can be created
SELECT * FROM redefine_all_listing_changes_mview();

CREATE OR REPLACE FUNCTION applicable_listing_changes_for_node(in_designation_id INT, node_id INT)
RETURNS SETOF INT
STABLE
AS $$

WITH RECURSIVE listing_changes_timeline AS (
  SELECT all_listing_changes_mview.id,
  designation_id,
  affected_taxon_concept_id AS original_taxon_concept_id,
  taxon_concept_id AS current_taxon_concept_id,
  HSTORE(species_listing_id::TEXT, taxon_concept_id::TEXT) AS context,
  inclusion_taxon_concept_id,
  species_listing_id,
  change_type_id,
  effective_at,
  tree_distance AS context_tree_distance,
  timeline_position,
  CASE
   WHEN (
    -- there are listed populations
    ARRAY_UPPER(listed_geo_entities_ids, 1) IS NOT NULL
    -- and the taxon does not occur in any of them
    AND NOT listed_geo_entities_ids && taxon_concepts_mview.countries_ids_ary
  )
  -- when all populations are excluded
  OR excluded_geo_entities_ids @> taxon_concepts_mview.countries_ids_ary
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
  ELSE
  TRUE 
  END AS is_applicable
  FROM all_listing_changes_mview
  JOIN taxon_concepts_mview ON all_listing_changes_mview.affected_taxon_concept_id = taxon_concepts_mview.id 
  WHERE designation_id = $1
  AND all_listing_changes_mview.affected_taxon_concept_id = $2
  AND timeline_position = 1

  UNION

  SELECT hi.id,
  hi.designation_id,
  listing_changes_timeline.original_taxon_concept_id,
  hi.taxon_concept_id,
  CASE
  WHEN hi.inclusion_taxon_concept_id IS NOT NULL
  AND (
    AVALS(listing_changes_timeline.context) @> ARRAY[hi.taxon_concept_id::TEXT]
    OR listing_changes_timeline.context = ''::HSTORE
  )
  THEN HSTORE(hi.species_listing_id::TEXT, hi.inclusion_taxon_concept_id::TEXT)
  WHEN change_types.name = 'DELETION'
  THEN --listing_changes_timeline.context - ARRAY[hi.taxon_concept_id]
  listing_changes_timeline.context - HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
  WHEN hi.tree_distance < listing_changes_timeline.context_tree_distance
  AND change_types.name = 'ADDITION'
  THEN HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
  WHEN hi.tree_distance <= listing_changes_timeline.context_tree_distance
  AND hi.affected_taxon_concept_id = hi.taxon_concept_id
  AND change_types.name = 'ADDITION'
  THEN HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
  -- changing this to <= breaks Ursus arctos isabellinus
  WHEN hi.tree_distance <= listing_changes_timeline.context_tree_distance
  AND change_types.name = 'ADDITION'
  THEN listing_changes_timeline.context || HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
  ELSE listing_changes_timeline.context
  END,
  hi.inclusion_taxon_concept_id,
  hi.species_listing_id,
  hi.change_type_id,
  hi.effective_at,
  CASE 
  WHEN hi.inclusion_taxon_concept_id IS NOT NULL
  OR hi.tree_distance < listing_changes_timeline.context_tree_distance
  THEN hi.tree_distance
  ELSE listing_changes_timeline.context_tree_distance
  END,
  hi.timeline_position,
  -- is applicable
  CASE
  WHEN (
    -- there are listed populations
    ARRAY_UPPER(hi.listed_geo_entities_ids, 1) IS NOT NULL
    -- and the taxon does not occur in any of them
    AND NOT hi.listed_geo_entities_ids && taxon_concepts_mview.countries_ids_ary
  )
  -- when all populations are excluded
  OR hi.excluded_geo_entities_ids @> taxon_concepts_mview.countries_ids_ary
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
  THEN TRUE
  WHEN listing_changes_timeline.context = ''::HSTORE  --this would be the case when deleted
  AND hi.change_type_name = 'ADDITION'
  THEN TRUE -- allows for re-listing
  WHEN hi.tree_distance < listing_changes_timeline.context_tree_distance
  THEN TRUE
  ELSE FALSE
  END
  FROM all_listing_changes_mview hi
  JOIN listing_changes_timeline
  ON hi.designation_id = listing_changes_timeline.designation_id
  AND listing_changes_timeline.original_taxon_concept_id = hi.affected_taxon_concept_id
  AND listing_changes_timeline.timeline_position + 1 = hi.timeline_position
  JOIN change_types ON hi.change_type_id = change_types.id
  JOIN taxon_concepts_mview ON hi.affected_taxon_concept_id = taxon_concepts_mview.id 
)
SELECT listing_changes_timeline.id
FROM listing_changes_timeline
WHERE is_applicable
ORDER BY timeline_position;
$$ LANGUAGE SQL;

COMMENT ON FUNCTION applicable_listing_changes_for_node(in_designation_id INT, node_id INT) IS
  'Returns applicable listing changes for a given node, including own and ancestors.';
