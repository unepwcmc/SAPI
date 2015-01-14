SELECT
  st.id,
  st.legacy_id,
  st.data->'kingdom_name' AS kingdom_name,
  st.data->'phylum_name' AS phylum_name,
  st.data->'class_name' AS class_name,
  st.data->'order_name' AS order_name,
  st.data->'family_name' AS family_name,
  st.data->'genus_name' AS genus_name,
  st.data->'species_name' AS species_name,
  st.full_name AS full_name,
  st.author_year,
  st.taxonomic_position AS taxonomic_position,
  st.data->'rank_name' AS rank_name,
  st.name_status,
  taxonomies.name AS taxonomy,
  taxonomies.id AS taxonomy_id,
  rf.citation AS reference,
  rf.id AS reference_id,
  rf.legacy_id AS reference_legacy_id,
  to_char(r.created_at, 'DD/MM/YYYY') AS created_at,
  uc.name AS created_by,
  to_char(r.updated_at, 'DD/MM/YYYY') AS updated_at,
  uu.name AS updated_by
FROM taxon_concepts st
JOIN taxonomies ON taxonomies.id = st.taxonomy_id
LEFT JOIN taxon_concept_references r
ON r.taxon_concept_id = st.id AND r.is_standard is false
LEFT JOIN "references" rf
ON r.reference_id = rf.id
LEFT JOIN users uc
ON r.created_by_id = uc.id
LEFT JOIN users uu
ON r.updated_by_id = uu.id
WHERE st.name_status IN ('A', 'N');
