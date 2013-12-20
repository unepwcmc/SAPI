DROP VIEW IF EXISTS valid_appendix_view;
CREATE VIEW valid_appendix_view AS
SELECT * FROM UNNEST(ARRAY['I', 'II', 'III', 'N']);
