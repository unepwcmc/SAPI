CREATE OR REPLACE FUNCTION trim_decimal_zero(NUMERIC) RETURNS NUMERIC
  LANGUAGE SQL IMMUTABLE
  AS $$
    SELECT REGEXP_REPLACE($1::TEXT,
      '\.0+',
      ''
    )::NUMERIC
  $$;

COMMENT ON FUNCTION trim_decimal_zero(NUMERIC) IS
  'For display purposes make 1.0 -> 1, while 1.5 remains 1.5.';
