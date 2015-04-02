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
