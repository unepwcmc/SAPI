DROP VIEW IF EXISTS synonyms_and_trade_names_view;
CREATE VIEW synonyms_and_trade_names_view AS
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
LEFT JOIN users uc
ON st.created_by_id = uc.id
LEFT JOIN users uu
ON st.updated_by_id = uu.id
WHERE st.name_status IN ('S', 'T');
