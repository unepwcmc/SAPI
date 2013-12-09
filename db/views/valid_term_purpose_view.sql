DROP VIEW IF EXISTS valid_term_purpose_view;
CREATE VIEW valid_term_purpose_view AS
SELECT
  terms.code AS term_code,
  terms.id AS term_id,
  purposes.code AS purpose_code,
  purposes.id AS purpose_id
FROM term_trade_codes_pairs
INNER JOIN trade_codes as terms ON terms.id = term_trade_codes_pairs.term_id
INNER JOIN trade_codes as purposes
  ON purposes.id = term_trade_codes_pairs.trade_code_id
  AND term_trade_codes_pairs.trade_code_type = 'Purpose'
  AND purposes.type = 'Purpose';
