DROP VIEW IF EXISTS valid_taxon_check_view;
CREATE VIEW valid_taxon_check_view AS
SELECT full_name AS taxon_check FROM taxon_concepts_mview
WHERE taxonomy_is_cites_eu AND cites_status = 'LISTED';
