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

CREATE OR REPLACE FUNCTION array_intersect(anyarray, anyarray)
  RETURNS anyarray
  language SQL
AS $FUNCTION$
    SELECT ARRAY(
        SELECT UNNEST($1)
        INTERSECT
        SELECT UNNEST($2)
    );
$FUNCTION$;

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

CREATE OR REPLACE FUNCTION squish(TEXT) RETURNS TEXT
  LANGUAGE SQL IMMUTABLE
  AS $$
    SELECT BTRIM(regexp_replace($1, E'\\s+', ' ', 'g'));
  $$;

COMMENT ON FUNCTION squish(TEXT) IS
  'Squishes whitespace characters in a string';

CREATE OR REPLACE FUNCTION squish_null(TEXT) RETURNS TEXT
  LANGUAGE SQL IMMUTABLE
  AS $$
    SELECT CASE WHEN SQUISH($1) = '' THEN NULL ELSE SQUISH($1) END;
  $$;

COMMENT ON FUNCTION squish_null(TEXT) IS
  'Squishes whitespace characters in a string and returns null for empty string';

CREATE OR REPLACE FUNCTION sanitize_species_name(TEXT) RETURNS TEXT
  LANGUAGE SQL IMMUTABLE
  AS $$
    SELECT regexp_replace(
      upper(substring(SQUISH_NULL($1) from 1 for 1)) ||
      lower(substring(SQUISH_NULL($1) from 2 for length(SQUISH_NULL($1)))),
      E' spp(\.)?$', '');
  $$;

COMMENT ON FUNCTION sanitize_species_name(TEXT) IS
  'Converts the case, removes spp. and squish_nulls the species name';

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
      WHEN $1 IN ('ORDER', 'FAMILY', 'SUBFAMILY', 'GENUS')
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

CREATE OR REPLACE FUNCTION drop_trade_sandboxes() RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    current_table_name TEXT;
  BEGIN
    FOR current_table_name IN SELECT table_name FROM information_schema.tables
    WHERE table_name LIKE 'trade_sandbox%'
      AND table_name != 'trade_sandbox_template'
      AND table_type != 'VIEW'
    LOOP
      EXECUTE 'DROP TABLE ' || current_table_name || ' CASCADE';
    END LOOP;
    RETURN;
  END;
  $$;

COMMENT ON FUNCTION drop_trade_sandboxes() IS '
Drops all trade_sandbox_n tables. Used in specs only, you need to know what
you''re doing. If you''re looking to drop all sandboxes in the live system,
use the rake db:drop_sandboxes task instead.';

CREATE OR REPLACE FUNCTION drop_eu_lc_mviews() RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    current_table_name TEXT;
  BEGIN
    FOR current_table_name IN SELECT table_name FROM information_schema.tables
    WHERE table_name LIKE 'eu_%_listing_changes_mview'
      AND table_type != 'VIEW'
    LOOP
      EXECUTE 'DROP TABLE ' || current_table_name || ' CASCADE';
    END LOOP;
    RETURN;
  END;
  $$;

CREATE OR REPLACE FUNCTION listing_changes_mview_name(prefix TEXT, designation TEXT, events_ids INT[])
  RETURNS TEXT
  LANGUAGE SQL IMMUTABLE
  AS $$
    SELECT CASE WHEN prefix IS NULL THEN '' ELSE prefix || '_' END ||
    designation ||
    CASE
      WHEN events_ids IS NOT NULL
      THEN '_' || ARRAY_TO_STRING(events_ids, '_')
      ELSE ''
    END || '_listing_changes_mview';
  $$;
