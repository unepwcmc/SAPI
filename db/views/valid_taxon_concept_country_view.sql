DROP VIEW IF EXISTS valid_species_name_exporter_view;
DROP VIEW IF EXISTS valid_species_name_country_of_origin_view;
DROP VIEW IF EXISTS valid_species_name_country_view;
DROP VIEW IF EXISTS valid_taxon_concept_exporter_view;
DROP VIEW IF EXISTS valid_taxon_concept_country_of_origin_view;
DROP VIEW IF EXISTS valid_taxon_concept_country_view;
CREATE VIEW valid_taxon_concept_country_view AS
SELECT
taxon_concepts.id AS taxon_concept_id,
geo_entities.iso_code2 AS iso_code2,
geo_entities.id AS geo_entity_id
FROM taxon_concepts
JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
  AND taxonomies.name = 'CITES_EU'
JOIN distributions
  ON distributions.taxon_concept_id = taxon_concepts.id
JOIN geo_entities
  ON geo_entities.id = distributions.geo_entity_id;


CREATE VIEW valid_taxon_concept_exporter_view AS
SELECT taxon_concept_id,
iso_code2 AS exporter, geo_entity_id AS exporter_id
FROM valid_taxon_concept_country_view;

CREATE VIEW valid_taxon_concept_country_of_origin_view AS
SELECT taxon_concept_id,
iso_code2 AS country_of_origin, geo_entity_id AS country_of_origin_id
FROM valid_taxon_concept_country_view;