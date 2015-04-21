CREATE OR REPLACE FUNCTION squish_null(TEXT) RETURNS TEXT
  LANGUAGE SQL IMMUTABLE
  AS $$
    SELECT CASE WHEN SQUISH($1) = '' THEN NULL ELSE SQUISH($1) END;
  $$;

COMMENT ON FUNCTION squish_null(TEXT) IS
  'Squishes whitespace characters in a string and returns null for empty string';
