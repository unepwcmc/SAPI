CREATE OR REPLACE FUNCTION public.squish_null(TEXT) RETURNS TEXT
  LANGUAGE SQL IMMUTABLE
AS $fn$
  SELECT
    CASE WHEN public.squish($1) = ''
    THEN NULL
    ELSE public.squish($1)
  END;
$fn$;

COMMENT ON FUNCTION public.squish_null(TEXT) IS
  'Squishes whitespace characters in a string and returns null for empty string';
