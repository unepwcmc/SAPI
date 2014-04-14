DROP VIEW IF EXISTS species_reference_output_view;
CREATE VIEW species_reference_output_view AS
SELECT
  st.id,
  st.legacy_id,
  st.data->'phylum_name' AS accepted_phylum_name,
  st.data->'class_name' AS accepted_class_name,
  st.data->'order_name' AS accepted_order_name,
  st.data->'family_name' AS accepted_family_name,
  st.data->'genus_name' AS accepted_genus_name,
  st.data->'species_name' AS accepted_species_name,
  st.full_name AS full_name,
  st.data->'rank_name' AS rank_name,
  st.name_status,
  taxonomies.name AS taxonomy,
  rf.citation AS reference,
  rf.id AS reference_id,
  rf.legacy_id AS reference_legacy_id,
  to_char(st.created_at, 'DD/MM/YYYY') AS created_at,
  'TODO' AS created_by
FROM taxon_concepts st
JOIN taxonomies ON taxonomies.id = st.taxonomy_id
LEFT JOIN taxon_concept_references r
ON r.taxon_concept_id = st.id AND r.is_standard is false
LEFT JOIN "references" rf
ON r.reference_id = rf.id
WHERE st.name_status IN ('A', 'N');

