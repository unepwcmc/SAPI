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
        -- the following ROW_NUMBER call will assign chronoligocal order to listing changes
        -- in scope of the affected taxon concept and a particular designation
        ROW_NUMBER() OVER (
            PARTITION BY designation_id, taxon_concept_and_ancestors.taxon_concept_id
            ORDER BY effective_at, tree_distance
        )::INT AS timeline_position
    FROM listing_changes
    JOIN (
      SELECT *, ROW_NUMBER() OVER(PARTITION BY taxon_concept_id) -1 AS tree_distance FROM (
        -- This subquery takes advantage of the fact that a set-returning SQL procedure
        -- (higher_or_equal_ranks_names) used in select clause can accept other select targets as
        -- parameters (the rank_name in this case) and will produce a number of
        -- records in the query result, i.e. for every taxon concept this will output all pairs
        -- of this taxon concept (taxon_concept_id) and its ancestors (ancestor_taxon_concept_id)
        -- However, ROW_NUMBER cannot be applied  directly here, because it would return
        -- the same number for every ancestor matching the same taxon concept
        -- which is why ROW_NUMBER is being called over this subquery in order to calculate
        -- the distance between the taxon concept and any of its ancestors; ROW_NUMBER will
        -- use the same order in which ancestors were returned, which is already correct
        SELECT id AS taxon_concept_id,
        (data->(LOWER(higher_or_equal_ranks_names(data->'rank_name')) || '_id'))::INT AS ancestor_taxon_concept_id
        FROM taxon_concepts
      ) q
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
  taxon_concept_id AS original_taxon_concept_id,
  taxon_concept_id AS current_taxon_concept_id,
  taxon_concept_id AS context,
  tree_distance AS context_tree_distance,
  timeline_position, TRUE AS is_applicable
  FROM all_listing_changes_mview
  WHERE designation_id = in_designation_id
  AND all_listing_changes_mview.affected_taxon_concept_id = node_id
  AND timeline_position = 1

  UNION

  SELECT hi.id,
  listing_changes_timeline.original_taxon_concept_id,
  hi.taxon_concept_id,
  CASE
  WHEN hi.inclusion_taxon_concept_id IS NOT NULL
  THEN hi.inclusion_taxon_concept_id
  WHEN hi.tree_distance < listing_changes_timeline.context_tree_distance
  THEN hi.taxon_concept_id
  ELSE listing_changes_timeline.context
  END,
  hi.tree_distance,
  hi.timeline_position,
  CASE
  WHEN hi.taxon_concept_id = listing_changes_timeline.context
  THEN TRUE
  WHEN hi.tree_distance < listing_changes_timeline.context_tree_distance
  THEN TRUE
  ELSE FALSE
  END
  FROM all_listing_changes_mview hi
  JOIN listing_changes_timeline
  ON designation_id = in_designation_id
  AND listing_changes_timeline.original_taxon_concept_id = hi.affected_taxon_concept_id
  AND listing_changes_timeline.timeline_position + 1 = hi.timeline_position
)
SELECT listing_changes_timeline.id
FROM listing_changes_timeline
WHERE is_applicable
ORDER BY timeline_position;
$$ LANGUAGE SQL;

COMMENT ON FUNCTION applicable_listing_changes_for_node(in_designation_id INT, node_id INT) IS
  'Returns applicable listing changes for a given node, including own and ancestors.';
