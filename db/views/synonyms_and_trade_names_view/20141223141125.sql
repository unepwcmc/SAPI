SELECT
  st.name_status,
  st.id,
  st.legacy_id,
  st.legacy_trade_code,
  st.data->'rank_name' AS rank_name,
  st.full_name,
  st.author_year,
  a.full_name AS accepted_full_name,
  a.author_year AS accepted_author_year,
  a.id AS accepted_id,
  a.data->'rank_name' AS accepted_rank_name,
  a.name_status AS accepted_name_status,
  a.data->'kingdom_name' AS accepted_kingdom_name,
  a.data->'phylum_name' AS accepted_phylum_name,
  a.data->'class_name' AS accepted_class_name,
  a.data->'order_name' AS accepted_order_name,
  a.data->'family_name' AS accepted_family_name,
  a.data->'genus_name' AS accepted_genus_name,
  a.data->'species_name' AS accepted_species_name,
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
  to_char(st.created_at, 'DD/MM/YYYY') AS created_at,
  uc.name AS created_by,
  to_char(st.updated_at, 'DD/MM/YYYY') AS updated_at,
  uu.name AS updated_by
FROM taxon_concepts st
JOIN taxonomies ON taxonomies.id = st.taxonomy_id
LEFT JOIN taxon_relationships
ON taxon_relationships.other_taxon_concept_id = st.id
LEFT JOIN taxon_concepts a
ON taxon_relationships.taxon_concept_id = a.id
LEFT JOIN  comments general_note
  ON general_note.commentable_id = st.id
  AND general_note.commentable_type = 'TaxonConcept'
  AND general_note.comment_type = 'General'
LEFT JOIN  comments nomenclature_note
  ON nomenclature_note.commentable_id = st.id
  AND nomenclature_note.commentable_type = 'TaxonConcept'
  AND nomenclature_note.comment_type = 'Nomenclature'
LEFT JOIN  comments distribution_note
  ON distribution_note.commentable_id = st.id
  AND distribution_note.commentable_type = 'TaxonConcept'
  AND distribution_note.comment_type = 'Distribution'
LEFT JOIN users uc
ON st.created_by_id = uc.id
LEFT JOIN users uu
ON st.updated_by_id = uu.id
WHERE st.name_status IN ('S', 'T');
