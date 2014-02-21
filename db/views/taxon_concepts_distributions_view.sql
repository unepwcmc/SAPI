DROP VIEW IF EXISTS taxon_concepts_distributions_view;
CREATE VIEW taxon_concepts_distributions_view AS
SELECT
  taxon_concepts.id AS id,
  taxon_concepts.legacy_id AS legacy_id,
  data->'phylum_name' AS phylum_name,
  data->'class_name' AS class_name,
  data->'order_name' AS order_name,
  data->'family_name' AS family_name,
  full_name,
  data->'rank_name' AS rank_name,
  geo_entity_types.name AS geo_entity_type,
  geo_entities.name_en AS geo_entity_name,
  geo_entities.iso_code2 AS geo_entity_iso_code2,
  string_agg(tags.name, ', ') AS tags,
  "references".citation AS reference_full,
  "references".id AS reference_id,
  "references".legacy_id AS reference_legacy_id,
  taxonomies.name AS taxonomy_name,
  taxonomic_position,
  taxonomy_id
FROM taxon_concepts
JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
INNER JOIN distributions ON distributions.taxon_concept_id = taxon_concepts.id
INNER JOIN geo_entities ON geo_entities.id = distributions.geo_entity_id
INNER JOIN geo_entity_types ON geo_entity_types.id = geo_entities.geo_entity_type_id
LEFT JOIN distribution_references ON distribution_references.distribution_id = distributions.id
LEFT JOIN "references" ON "references".id = distribution_references.reference_id
LEFT JOIN taggings ON taggings.taggable_id = distributions.id 
  AND taggings.taggable_type = 'Distribution'    
LEFT JOIN tags ON tags.id = taggings.tag_id
GROUP BY taxon_concepts.id, taxon_concepts.legacy_id, geo_entity_types.name,
  geo_entities.name_en, geo_entities.iso_code2, "references".citation, "references".id,
  taxonomies.name
