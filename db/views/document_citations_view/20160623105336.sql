SELECT
  dc.id,
  dc.document_id,
  dctc.taxon_concept_id,
  tc.full_name,
  dcge.geo_entity_id,
  ge.name_en
FROM document_citations dc
LEFT JOIN document_citation_taxon_concepts dctc
  ON dctc.document_citation_id = dc.id
LEFT JOIN taxon_concepts tc
  ON tc.id = dctc.taxon_concept_id
LEFT JOIN document_citation_geo_entities dcge
  ON dcge.document_citation_id = dc.id
LEFT JOIN geo_entities ge
  ON ge.id = dcge.geo_entity_id
GROUP BY
  dc.id,
  document_id,
  taxon_concept_id,
  full_name,
  geo_entity_id,
  name_en;
