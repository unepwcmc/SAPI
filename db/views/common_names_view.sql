DROP VIEW IF EXISTS common_names_view;
CREATE VIEW common_names_view AS

SELECT
  st.name_status,
  st.id,
  st.data->'phylum_name' AS accepted_phylum_name,
  st.data->'class_name' AS accepted_class_name,
  st.data->'order_name' AS accepted_order_name,
  st.data->'family_name' AS accepted_family_name,
  st.full_name AS full_name,
  st.author_year,
  st.data->'rank_name' AS rank_name,
  st.taxonomic_position,
  n.name AS common_name,
  l.name_en AS common_name_language,
  taxonomies.name AS taxonomy_name,
  to_char(st.created_at, 'DD/MM/YYYY') AS created_at,
  'TODO' AS created_by,
  taxonomies.id AS taxonomy_id

FROM taxon_concepts st
JOIN taxonomies ON taxonomies.id = st.taxonomy_id
LEFT JOIN taxon_commons c
ON c.taxon_concept_id = st.id
LEFT JOIN common_names n
ON c.common_name_id = n.id
LEFT JOIN languages as l
ON n.language_id = l.id

WHERE st.name_status IN ('A');