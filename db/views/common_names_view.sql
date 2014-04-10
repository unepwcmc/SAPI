DROP VIEW IF EXISTS common_names_view;
CREATE VIEW common_names_view AS
SELECT
  st.id,
  a.data->'phylum_name' AS accepted_phylum_name,
  a.data->'class_name' AS accepted_class_name,
  a.data->'order_name' AS accepted_order_name,
  a.data->'family_name' AS accepted_family_name,
  st.full_name AS scientific_name,
  st.author_year,
  a.data->'rank_name' AS accepted_rank_name,
  n.name AS common_name,
  l.name_en AS common_name_language,
  taxonomies.name AS taxonomy_name,
  to_char(st.created_at, 'DD/MM/YYYY') AS created_at,
  'TODO' AS created_by
FROM taxon_concepts st
JOIN taxonomies ON taxonomies.id = st.taxonomy_id
LEFT JOIN taxon_relationships
ON taxon_relationships.other_taxon_concept_id = st.id
LEFT JOIN taxon_concepts a
ON taxon_relationships.taxon_concept_id = a.id
LEFT JOIN taxon_commons c
ON c.taxon_concept_id = a.id
LEFT JOIN common_names n
ON c.common_name_id = n.id
LEFT JOIN languages as l
ON n.language_id = l.id
WHERE st.name_status IN ('S', 'T');