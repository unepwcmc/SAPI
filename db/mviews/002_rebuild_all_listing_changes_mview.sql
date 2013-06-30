CREATE OR REPLACE FUNCTION higher_or_equal_ranks_names(in_rank_name character varying)
  RETURNS TEXT[]
AS
$BODY$
    WITH ranks_in_order(row_no, rank_name) AS (
      SELECT ROW_NUMBER() OVER(), *
      FROM UNNEST(ARRAY[
      'VARIETY', 'SUBSPECIES', 'SPECIES', 'GENUS',
      'FAMILY', 'ORDER', 'CLASS', 'PHYLUM', 'KINGDOM'
      ])
    )
    SELECT ARRAY_AGG(rank_name) FROM ranks_in_order
    WHERE row_no >= (SELECT row_no FROM ranks_in_order WHERE rank_name = in_rank_name);
  $BODY$
  LANGUAGE sql IMMUTABLE;

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

    CREATE INDEX ON all_listing_changes_mview (designation_id, affected_taxon_concept_id);
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

    RAISE NOTICE 'Creating all listing changes view';
    CREATE VIEW all_listing_changes_view AS
    -- affected_taxon_concept -- is a taxon concept that is affected by this listing change,
    -- even though it might not have an explicit connection to it
    -- (i.e. it's an ancestor's listing change)
    SELECT
        listing_changes.id,
        designation_id,
        listing_changes.taxon_concept_id,
        taxon_concept_and_ancestors.taxon_concept_id AS affected_taxon_concept_id,
        taxon_concept_and_ancestors.tree_distance,
        species_listing_id,
        change_type_id,
        inclusion_taxon_concept_id,
        effective_at::DATE,
        -- the following ROW_NUMBER call will assign chronologocal order to listing changes
        -- in scope of the affected taxon concept and a particular designation
        ROW_NUMBER() OVER (
            PARTITION BY taxon_concept_and_ancestors.taxon_concept_id, designation_id
            ORDER BY effective_at, tree_distance,
            CASE
              WHEN change_types.name = 'ADDITION' THEN 0
              WHEN change_types.name = 'RESERVATION' THEN 1
              WHEN change_types.name = 'RESERVATION_WITHDRAWAL' THEN 2
              WHEN change_types.name = 'DELETION' THEN 3
              WHEN change_types.name = 'EXCEPTION' THEN 4
            END,
            tree_distance
        )::INT AS timeline_position
    FROM listing_changes
    JOIN (
        -- This subquery took like half a day to get right, so maybe it deserves a comment.
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
        FROM taxon_concepts
    ) taxon_concept_and_ancestors
    ON listing_changes.taxon_concept_id = taxon_concept_and_ancestors.ancestor_taxon_concept_id
    JOIN change_types ON change_types.id = listing_changes.change_type_id;
  END;
  $$;

--this line is here so that the following procedure, which depends on this materialized view, can be created
SELECT * FROM redefine_all_listing_changes_mview() ;

CREATE OR REPLACE FUNCTION applicable_listing_changes_for_node(in_designation_id INT, node_id INT)
RETURNS SETOF  INT
STABLE
AS $$

WITH RECURSIVE listing_changes_timeline AS (
  SELECT id,
  designation_id,
  affected_taxon_concept_id AS original_taxon_concept_id,
  taxon_concept_id AS current_taxon_concept_id,
  taxon_concept_id AS context,
  inclusion_taxon_concept_id,
  species_listing_id,
  change_type_id,
  effective_at,
  tree_distance AS context_tree_distance,
  timeline_position,
  TRUE AS is_applicable
  FROM all_listing_changes_mview
  WHERE designation_id = in_designation_id
  AND all_listing_changes_mview.affected_taxon_concept_id = node_id
  AND timeline_position = 1

  UNION

  SELECT hi.id,
  hi.designation_id,
  listing_changes_timeline.original_taxon_concept_id,
  hi.taxon_concept_id,
  CASE
  WHEN hi.inclusion_taxon_concept_id IS NOT NULL
  THEN hi.inclusion_taxon_concept_id
  WHEN change_types.name = 'DELETION'
  THEN NULL
  WHEN hi.tree_distance < listing_changes_timeline.context_tree_distance
  AND change_types.name = 'ADDITION'
  THEN hi.taxon_concept_id
  ELSE listing_changes_timeline.context
  END,
  hi.inclusion_taxon_concept_id,
  hi.species_listing_id,
  hi.change_type_id,
  hi.effective_at,
  hi.tree_distance,
  hi.timeline_position,
  -- is applicable
  CASE
  WHEN listing_changes_timeline.inclusion_taxon_concept_id IS NOT NULL
  AND listing_changes_timeline.inclusion_taxon_concept_id = hi.taxon_concept_id
  AND listing_changes_timeline.species_listing_id = hi.species_listing_id
  AND listing_changes_timeline.change_type_id = hi.change_type_id
  AND listing_changes_timeline.effective_at = hi.effective_at
  THEN FALSE
  WHEN hi.taxon_concept_id = listing_changes_timeline.context
  THEN TRUE
  WHEN listing_changes_timeline.context IS NULL --this would be the case when deleted
  THEN FALSE
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
)
SELECT listing_changes_timeline.id
FROM listing_changes_timeline
WHERE is_applicable
ORDER BY timeline_position;
$$ LANGUAGE SQL;

COMMENT ON FUNCTION applicable_listing_changes_for_node(in_designation_id INT, node_id INT) IS
  'Returns applicable listing changes for a given node, including own and ancestors.';
