SELECT d.id,
  d.event_id,
  e.name AS event_name,
  CASE
      WHEN e.published_at IS NOT NULL THEN to_char(e.published_at, 'DD/MM/YYYY'::text)
      ELSE to_char(d.date::timestamp with time zone, 'DD/MM/YYYY'::text)
  END AS date,
  CASE
      WHEN e.published_at IS NOT NULL THEN e.published_at
      ELSE d.date::timestamp with time zone
  END AS date_raw,
  e.type AS event_type,
  d.title,
  upper("substring"(d.filename, length(d.filename) - "position"(reverse(d.filename), '.'::text) + 2)) AS extension,
  d.is_public,
  d.type AS document_type,
  d.number,
  d.sort_index,
  CASE
      WHEN l.iso_code1 IS NULL THEN 'EN'::character varying(255)
      ELSE l.iso_code1
  END AS language,
  CASE
      WHEN d.primary_language_document_id IS NULL THEN d.id
      ELSE d.primary_language_document_id
  END AS primary_document_id,
  po.name AS proposal_outcome,
  rp.name AS review_phase,
  array_agg_notnull(po.id) || array_agg_notnull(rp.id) AS document_tags_ids,
  array_agg_notnull(dctc.taxon_concept_id) AS taxon_concept_ids,
  array_agg_notnull(DISTINCT tc.full_name ORDER BY tc.full_name) AS taxon_names,
  array_agg_notnull(dcge.geo_entity_id) AS geo_entity_ids,
  array_agg_notnull(DISTINCT ge.name_en ORDER BY ge.name_en) AS geo_entity_names
 FROM documents d
   LEFT JOIN events e ON e.id = d.event_id
   LEFT JOIN document_citations dc ON dc.document_id = d.id
   LEFT JOIN document_citation_taxon_concepts dctc ON dctc.document_citation_id = dc.id
   LEFT JOIN taxon_concepts tc ON dctc.taxon_concept_id = tc.id
   LEFT JOIN document_citation_geo_entities dcge ON dcge.document_citation_id = dc.id
   LEFT JOIN geo_entities ge ON dcge.geo_entity_id = ge.id
   LEFT JOIN languages l ON d.language_id = l.id
   LEFT JOIN proposal_details pd ON d.id = pd.id
   LEFT JOIN document_tags po ON pd.proposal_outcome_id = po.id
   LEFT JOIN review_details rd ON rd.document_id = d.id
   LEFT JOIN document_tags rp ON rd.review_phase_id = rp.id
GROUP BY d.id, e.name, e.published_at, e.type, d.title, l.iso_code1, po.name, rp.name;
