DROP VIEW IF EXISTS valid_taxon_check_view;
CREATE VIEW valid_taxon_check_view AS
SELECT full_name AS taxon_check FROM taxon_concepts
JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
WHERE taxonomies.name = 'CITES_EU';
