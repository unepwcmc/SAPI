SELECT
  tc.name_status,
  tc.id,
  tc.legacy_id,
  tc.legacy_trade_code,
  tc.data->'rank_name' AS rank_name,
  tc.full_name,
  tc.author_year,
  taxonomies.id AS taxonomy_id,
  taxonomies.name AS taxonomy_name,
  ARRAY_TO_STRING(
    ARRAY[
      general_note.note,
      nomenclature_note.note,
      distribution_note.note
    ],
    E'\n'
  ) AS internal_notes,
  to_char(tc.created_at, 'DD/MM/YYYY') AS created_at,
  uc.name AS created_by,
  to_char(tc.updated_at, 'DD/MM/YYYY') AS updated_at,
  uu.name AS updated_by
FROM taxon_concepts tc
JOIN taxonomies ON taxonomies.id = tc.taxonomy_id
LEFT JOIN taxon_relationships tr1 ON tr1.taxon_concept_id = tc.id
LEFT JOIN taxon_relationships tr2 ON tr2.other_taxon_concept_id = tc.id
LEFT JOIN taxon_concepts children ON children.parent_id = tc.id
LEFT JOIN  comments general_note
  ON general_note.commentable_id = tc.id
  AND general_note.commentable_type = 'TaxonConcept'
  AND general_note.comment_type = 'General'
LEFT JOIN  comments nomenclature_note
  ON nomenclature_note.commentable_id = tc.id
  AND nomenclature_note.commentable_type = 'TaxonConcept'
  AND nomenclature_note.comment_type = 'Nomenclature'
LEFT JOIN  comments distribution_note
  ON distribution_note.commentable_id = tc.id
  AND distribution_note.commentable_type = 'TaxonConcept'
  AND distribution_note.comment_type = 'Distribution'
LEFT JOIN users uc ON tc.created_by_id = uc.id
LEFT JOIN users uu ON tc.updated_by_id = uu.id
WHERE tc.parent_id IS NULL
  AND tr1.id IS NULL
  AND tr2.id IS NULL
  AND children.id IS NULL;
