--Id  
--Legacy id 
--Kingdom Phylum Class Order Family Genus Species
--Scientific Name 
--Author  
--Rank  
--Name status 
--Taxonomy  
--Reference 
--Reference IDs 
--Ref Legacy ID 
--CITES Standard Reference  
--CITES Std. Ref Inherited from 
--Taxa excluded from Std. Ref 
--Std Ref Cascades  
--Date added  
--Added by  
--Date updated  
--Updated by

DROP VIEW IF EXISTS synonyms_and_trade_names_view;
CREATE VIEW synonyms_and_trade_names_view AS
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

  rf.title,

  to_char(st.created_at, 'DD/MM/YYYY') AS created_at,
  'TODO' AS created_by
  
FROM taxon_concepts st
JOIN taxonomies ON taxonomies.id = st.taxonomy_id
LEFT JOIN taxon_concept_references r
ON r.taxon_concept_id = st.id AND r.is_standard is false
LEFT JOIN "references" rf
ON r.reference_id = rf.id

WHERE st.name_status IN ('A', 'N');