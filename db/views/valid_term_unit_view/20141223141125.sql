SELECT
  terms.code AS term_code,
  terms.id AS term_id,
  units.code AS unit_code,
  units.id AS unit_id
FROM term_trade_codes_pairs
INNER JOIN trade_codes as units
  ON units.id = term_trade_codes_pairs.trade_code_id
  AND term_trade_codes_pairs.trade_code_type = 'Unit'
  AND units.type = 'Unit'
INNER JOIN trade_codes as terms ON terms.id = term_trade_codes_pairs.term_id
UNION
SELECT
  terms.code AS term_code,
  terms.id AS term_id,
  NULL AS unit_code,
  NULL AS unit_id
FROM term_trade_codes_pairs
INNER JOIN trade_codes as terms ON terms.id = term_trade_codes_pairs.term_id
WHERE term_trade_codes_pairs.trade_code_type = 'Unit'
  AND term_trade_codes_pairs.trade_code_id IS NULL;

