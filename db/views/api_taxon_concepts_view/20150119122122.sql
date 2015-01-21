SELECT
  tc.id,
  tc.parent_id,
  taxonomies.name,
  CASE WHEN taxonomies.name = 'CITES_EU' THEN TRUE ELSE FALSE END AS taxonomy_is_cites_eu,
  tc.full_name,
  tc.author_year,
  'A' AS name_status,
  ranks.name AS rank,
  tc.taxonomic_position,
  tc.listing->'cites_listing' AS cites_listing,
  tc.data->'kingdom_name' AS kingdom_name,
  tc.data->'phylum_name' AS phylum_name,
  tc.data->'class_name' AS class_name,
  tc.data->'order_name' AS order_name,
  tc.data->'family_name' AS family_name,
  tc.data->'genus_name' AS genus_name,
  ROW_TO_JSON(
    ROW(
      tc.data->'kingdom_name',
      tc.data->'phylum_name',
      tc.data->'class_name',
      tc.data->'order_name',
      tc.data->'family_name'
    )::api_higher_taxa
  ) AS higher_taxa,
  ARRAY_TO_JSON(
    ARRAY_AGG_NOTNULL(
      ROW(
        synonyms.id, synonyms.full_name, synonyms.author_year, synonyms.data->'rank_name'
      )::api_taxon_concept
    )
  ) AS synonyms,
  NULL AS accepted_names,
  tc.created_at,
  tc.updated_at
FROM taxon_concepts tc
JOIN taxonomies ON taxonomies.id = tc.taxonomy_id
JOIN ranks ON ranks.id = tc.rank_id
LEFT JOIN taxon_relationships tr
  ON tr.taxon_concept_id = tc.id
LEFT JOIN taxon_relationship_types trt
  ON trt.id = tr.taxon_relationship_type_id AND trt.name = 'HAS_SYNONYM'
LEFT JOIN taxon_concepts synonyms
  ON synonyms.id = tr.other_taxon_concept_id AND synonyms.taxonomy_id = taxonomies.id
WHERE tc.name_status = 'A'
GROUP BY tc.id, tc.parent_id, taxonomies.name, tc.full_name, tc.author_year, ranks.name,
tc.taxonomic_position,
tc.created_at, tc.updated_at

UNION ALL

SELECT
  tc.id,
  NULL AS parent_id,
  taxonomies.name,
  CASE WHEN taxonomies.name = 'CITES' THEN TRUE ELSE FALSE END AS taxonomy_is_cites_eu,
  tc.full_name,
  tc.author_year,
  'S' AS name_status,
  ranks.name AS rank,
  NULL AS taxonomic_position,
  NULL AS cites_listing,
  NULL AS kingdom_name,
  NULL AS phylum_name,
  NULL AS class_name,
  NULL AS order_name,
  NULL AS family_name,
  NULL AS genus_name,
  NULL::JSON AS higher_taxa,
  NULL AS synonyms,
  ARRAY_TO_JSON(
    ARRAY_AGG_NOTNULL(
      ROW(
        accepted_names.id, accepted_names.full_name, accepted_names.author_year, accepted_names.data->'rank_name'
      )::api_taxon_concept
    )
  ) AS accepted_names,
  tc.created_at,
  tc.updated_at
FROM taxon_concepts tc
JOIN taxonomies ON taxonomies.id = tc.taxonomy_id
JOIN ranks ON ranks.id = tc.rank_id
JOIN taxon_relationships tr
  ON tr.other_taxon_concept_id = tc.id
JOIN taxon_relationship_types trt
  ON trt.id = tr.taxon_relationship_type_id AND trt.name = 'HAS_SYNONYM'
JOIN taxon_concepts accepted_names
  ON accepted_names.id = tr.taxon_concept_id AND accepted_names.taxonomy_id = taxonomies.id
WHERE tc.name_status = 'S'
GROUP BY tc.id, tc.parent_id, taxonomies.name, tc.full_name, tc.author_year, ranks.name,
tc.taxonomic_position,
tc.created_at, tc.updated_at;