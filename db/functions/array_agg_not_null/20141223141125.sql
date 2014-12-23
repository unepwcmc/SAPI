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
