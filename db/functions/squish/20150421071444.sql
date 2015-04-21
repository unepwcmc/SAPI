CREATE OR REPLACE FUNCTION squish(TEXT) RETURNS TEXT
  LANGUAGE SQL IMMUTABLE
  AS $$
    SELECT BTRIM(regexp_replace($1, E'\\s+', ' ', 'g'));
  $$;

COMMENT ON FUNCTION squish(TEXT) IS
  'Squishes whitespace characters in a string';
