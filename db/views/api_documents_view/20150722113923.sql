SELECT
  d.id, e.name AS event_name, e.published_at AS event_date,
  e.type AS event_type, d.title,
  ARRAY_AGG_NOTNULL(dctc.taxon_concept_id) AS taxon_concept_ids
FROM documents d
LEFT JOIN events e ON e.id = d.event_id
LEFT JOIN document_citations dc ON dc.document_id = d.id
LEFT JOIN document_citation_taxon_concepts dctc
  ON dctc.document_citation_id = dc.id
LEFT JOIN document_citation_geo_entities dcge
  ON dcge.document_citation_id = dc.id
GROUP BY d.id, e.name, e.published_at, e.type, d.title
