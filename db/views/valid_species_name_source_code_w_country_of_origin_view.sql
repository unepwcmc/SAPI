DROP VIEW IF EXISTS valid_species_name_country_view;
CREATE VIEW valid_species_name_country_view AS
SELECT full_name AS species_name,
geo_entities.iso_code2 AS iso_code2
FROM taxon_concepts
JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
  AND taxonomies.name = 'CITES_EU'
JOIN distributions
  ON distributions.taxon_concept_id = taxon_concepts.id
JOIN geo_entities
  ON geo_entities.id = distributions.geo_entity_id;

DROP VIEW IF EXISTS valid_species_name_country_of_origin_view;
CREATE VIEW valid_species_name_country_of_origin_view AS
SELECT species_name, iso_code2 AS country_of_origin
FROM valid_species_name_country_view;