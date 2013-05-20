DROP VIEW IF EXISTS valid_term_code_view;
CREATE VIEW valid_term_code_view AS
SELECT code AS term_code FROM trade_codes
WHERE type='Term';

DROP VIEW IF EXISTS valid_source_code_view;
CREATE VIEW valid_source_code_view AS
SELECT code AS source_code FROM trade_codes
WHERE type='Source';

DROP VIEW IF EXISTS valid_purpose_code_view;
CREATE VIEW valid_purpose_code_view AS
SELECT code AS purpose_code FROM trade_codes
WHERE type='Purpose';

DROP VIEW IF EXISTS valid_unit_code_view;
CREATE VIEW valid_unit_code_view AS
SELECT code AS unit_code FROM trade_codes
WHERE type='Unit';
