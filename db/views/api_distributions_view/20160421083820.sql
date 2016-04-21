SELECT
  d.*,
  g.name_en,
  g.name_es,
  g.name_fr,
  g.iso_code2,
  gt.name AS geo_entity_type,
  ARRAY_AGG_NOTNULL(r.citation ORDER BY r.citation) AS citations
FROM (
  SELECT
    d.id,
    d.taxon_concept_id,
    d.geo_entity_id,
    ARRAY_AGG_NOTNULL(tags.name ORDER BY taggings.created_at) AS tags
  FROM distributions d
  LEFT JOIN taggings ON taggings.taggable_type='Distribution' AND taggings.taggable_id=d.id
  LEFT JOIN tags on tags.id = taggings.tag_id
  GROUP BY d.id, d.taxon_concept_id, d.geo_entity_id
) d
JOIN geo_entities g ON g.id = d.geo_entity_id
JOIN geo_entity_types gt ON gt.id = g.geo_entity_type_id
LEFT JOIN distribution_references dr ON dr.distribution_id = d.id
LEFT JOIN "references" r ON r.id = dr.reference_id
GROUP BY d.id, d.taxon_concept_id, d.geo_entity_id, d.tags, g.name_en, g.name_es, g.name_fr, g.iso_code2, gt.name;