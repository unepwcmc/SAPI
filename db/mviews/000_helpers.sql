/*
With reference to
http://ejrh.wordpress.com/2011/09/27/denormalisation-aggregate-function-for-postgresql/
*/
CREATE OR REPLACE FUNCTION fn_array_agg_notnull (
    a anyarray
    , b anyelement
) RETURNS ANYARRAY
AS $$
BEGIN

    IF b IS NOT NULL THEN
        a := array_append(a, b);
    END IF;

    RETURN a;

END;
$$ IMMUTABLE LANGUAGE 'plpgsql';

DROP AGGREGATE IF EXISTS array_agg_notnull(ANYELEMENT) CASCADE;

CREATE AGGREGATE array_agg_notnull(ANYELEMENT) (
    SFUNC = fn_array_agg_notnull,
    STYPE = ANYARRAY,
    INITCOND = '{}'
);

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

CREATE OR REPLACE FUNCTION strip_tags(TEXT) RETURNS TEXT
  LANGUAGE SQL IMMUTABLE
  AS $$
    SELECT regexp_replace(regexp_replace($1, E'(?x)<[^>]*?(\s alt \s* = \s* ([\'"]) ([^>]*?) \2) [^>]*? >', E'\3'), E'(?x)(< [^>]*? >)', '', 'g')
  $$;

COMMENT ON FUNCTION strip_tags(TEXT) IS
  'Strips html tags from string using a regexp.';

CREATE OR REPLACE FUNCTION full_name_with_spp(rank_name VARCHAR(255), full_name VARCHAR(255)) RETURNS VARCHAR(255)
  LANGUAGE sql IMMUTABLE
  AS $$
    SELECT CASE
      WHEN $1 IN ('ORDER', 'FAMILY', 'GENUS')
      THEN $2 || ' spp.'
      ELSE $2
    END;
  $$;

COMMENT ON FUNCTION full_name_with_spp(rank_name VARCHAR(255), full_name VARCHAR(255)) IS
  'Returns full name with ssp where applicable depending on rank.';

CREATE OR REPLACE FUNCTION ancestor_listing_auto_note(rank_name VARCHAR(255), full_name VARCHAR(255), change_type_name VARCHAR(255))
RETURNS TEXT
  LANGUAGE sql IMMUTABLE
  AS $$
    SELECT $1 || ' ' ||
    CASE
      WHEN $3 = 'DELETION' THEN 'deletion'
      WHEN $3 = 'RESERVATION' THEN 'reservation'
      WHEN $3 = 'RESERVATION_WITHDRAWAL' THEN 'reservaton withdrawn'
      ELSE 'listing'
    END || ' ' || full_name_with_spp($1, $2);
  $$;

COMMENT ON FUNCTION ancestor_listing_auto_note(rank_name VARCHAR(255), full_name VARCHAR(255), change_type_name VARCHAR(255)) IS
  'Returns auto note (used for inherited listing changes).';

CREATE OR REPLACE FUNCTION rebuild_mviews() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    PERFORM rebuild_taxon_concepts_mview();
    PERFORM rebuild_listing_changes_mview();
  END;
  $$;

COMMENT ON FUNCTION rebuild_mviews() IS 'Procedure to rebuild materialized views in the database.';
