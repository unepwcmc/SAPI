DROP VIEW IF EXISTS valid_species_name_view;
DROP VIEW IF EXISTS valid_taxon_name_view;
CREATE VIEW valid_taxon_name_view AS
SELECT full_name AS taxon_name FROM taxon_concepts
JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
WHERE taxonomies.name = 'CITES_EU';
