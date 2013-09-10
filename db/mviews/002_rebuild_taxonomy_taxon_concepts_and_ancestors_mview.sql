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

COMMENT ON FUNCTION higher_or_equal_ranks_names(in_rank_name VARCHAR(255)) IS
  'Returns an array of rank names above the given rank (sorted lowest first).';

CREATE OR REPLACE FUNCTION rebuild_taxonomy_taxon_concepts_and_ancestors_mview(taxonomy taxonomies) RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    tc_table_name TEXT;
    sql TEXT;
  BEGIN
    SELECT LOWER(taxonomy.name) || '_taxon_concepts_and_ancestors_mview' INTO tc_table_name;

    RAISE NOTICE '* creating % tmp table', tc_table_name;
    EXECUTE 'DROP TABLE IF EXISTS ' || tc_table_name;

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

    sql := 'CREATE TEMP TABLE ' || tc_table_name || ' AS
    SELECT id AS taxon_concept_id,
    (
      data->(LOWER(UNNEST(higher_or_equal_ranks_names(data->''rank_name''))) || ''_id'')
    )::INT AS ancestor_taxon_concept_id,
    GENERATE_SUBSCRIPTS(higher_or_equal_ranks_names(data->''rank_name''), 1) - 1 AS tree_distance
    FROM taxon_concepts
    WHERE taxonomy_id = ' || taxonomy.id;

    EXECUTE sql;

    EXECUTE 'CREATE INDEX ON ' || tc_table_name || ' (ancestor_taxon_concept_id)';
  END
  $$;

COMMENT ON FUNCTION rebuild_taxonomy_taxon_concepts_and_ancestors_mview(taxonomy taxonomies) IS
  'Procedure to create a helper table with all taxon - ancestor pairs in a given taxonomy.';