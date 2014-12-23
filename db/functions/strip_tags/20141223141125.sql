CREATE OR REPLACE FUNCTION strip_tags(TEXT) RETURNS TEXT
  LANGUAGE SQL IMMUTABLE
  AS $$
    SELECT regexp_replace(regexp_replace($1, E'(?x)<[^>]*?(\s alt \s* = \s* ([\'"]) ([^>]*?) \2) [^>]*? >', E'\3'), E'(?x)(< [^>]*? >)', '', 'g')
  $$;

COMMENT ON FUNCTION strip_tags(TEXT) IS
  'Strips html tags from string using a regexp.';
