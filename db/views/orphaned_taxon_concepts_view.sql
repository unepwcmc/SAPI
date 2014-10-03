DROP VIEW IF EXISTS orphaned_taxon_concepts_view;
CREATE VIEW orphaned_taxon_concepts_view AS
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
      tc.internal_general_note,
      tc.internal_nomenclature_note,
      tc.internal_distribution_note
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
LEFT JOIN users uc ON tc.created_by_id = uc.id
LEFT JOIN users uu ON tc.updated_by_id = uu.id
WHERE tc.parent_id IS NULL
  AND tr1.id IS NULL
  AND tr2.id IS NULL
  AND children.id IS NULL;
