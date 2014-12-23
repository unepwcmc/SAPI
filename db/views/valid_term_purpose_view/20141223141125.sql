SELECT
  terms.code AS term_code,
  terms.id AS term_id,
  purposes.code AS purpose_code,
  purposes.id AS purpose_id
FROM term_trade_codes_pairs
INNER JOIN trade_codes as purposes
  ON purposes.id = term_trade_codes_pairs.trade_code_id
  AND term_trade_codes_pairs.trade_code_type = 'Purpose'
  AND purposes.type = 'Purpose'
INNER JOIN trade_codes as terms ON terms.id = term_trade_codes_pairs.term_id
UNION
SELECT
  terms.code AS term_code,
  terms.id AS term_id,
  NULL AS purpose_code,
  NULL AS purpose_id
FROM term_trade_codes_pairs
INNER JOIN trade_codes as terms ON terms.id = term_trade_codes_pairs.term_id
WHERE term_trade_codes_pairs.trade_code_type = 'Purpose'
  AND term_trade_codes_pairs.trade_code_id IS NULL;
