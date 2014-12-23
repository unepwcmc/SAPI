SELECT
taxon_concepts.id AS taxon_concept_id,
geo_entities.iso_code2 AS exporter,
geo_entities.id AS exporter_id
FROM taxon_concepts
JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
  AND taxonomies.name = 'CITES_EU'
JOIN distributions
  ON distributions.taxon_concept_id = taxon_concepts.id
JOIN geo_entities
  ON geo_entities.id = distributions.geo_entity_id;
