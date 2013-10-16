DROP VIEW IF EXISTS valid_term_unit_view;
CREATE VIEW valid_term_unit_view AS
SELECT
  terms.code AS term_code,
  units.code AS unit_code
FROM term_trade_codes_pairs
INNER JOIN trade_codes as terms ON terms.id = term_trade_codes_pairs.term_id
INNER JOIN trade_codes as units
  ON units.id = term_trade_codes_pairs.trade_code_id
  AND term_trade_codes_pairs.trade_code_type = 'Unit'
  AND units.type = 'Unit';
