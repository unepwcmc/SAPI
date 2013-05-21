DROP VIEW IF EXISTS valid_species_name_view;
CREATE VIEW valid_species_name_view AS
SELECT full_name AS species_name FROM taxon_concepts
JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
WHERE taxonomies.name = 'CITES_EU';
