WITH synonyms_segmented(taxon_concept_id, full_name, matched_taxon_concept_id, matched_name, matched_name_segment) AS (
  SELECT
    atc.id,
    atc.full_name,
    tc.id,
    tc.full_name,
    UPPER(REGEXP_SPLIT_TO_TABLE(tc.full_name, ' '))
  FROM taxon_concepts tc
  JOIN taxon_relationships tr
  ON tr.other_taxon_concept_id = tc.id
  JOIN taxon_relationship_types trt
  ON trt.id = tr.taxon_relationship_type_id
  AND trt.name = 'HAS_SYNONYM'
  JOIN taxon_concepts atc
  ON atc.id = tr.taxon_concept_id
  WHERE tc.name_status = 'S' AND atc.name_status = 'A'
), scientific_names_segmented(taxon_concept_id, full_name, matched_taxon_concept_id, matched_name, matched_name_segment) AS (
  SELECT
    id,
    taxon_concepts.full_name,
    id,
    taxon_concepts.full_name,
    UPPER(REGEXP_SPLIT_TO_TABLE(full_name, ' '))
  FROM taxon_concepts
), common_names_segmented(taxon_concept_id, full_name, matched_taxon_concept_id, matched_name, matched_name_segment) AS (
  SELECT
    taxon_concept_id,
    taxon_concepts.full_name,
    NULL::INT,
    common_names.name,
    UPPER(REGEXP_SPLIT_TO_TABLE(common_names.name, E'\\s|'''))
  FROM taxon_commons
  JOIN taxon_concepts
  ON taxon_commons.taxon_concept_id = taxon_concepts.id
  JOIN common_names
  ON common_names.id = taxon_commons.common_name_id
  JOIN languages
  ON languages.id = common_names.language_id
  AND languages.iso_code1 IN ('EN', 'ES', 'FR')
), all_names_segmented_cleaned AS (
  SELECT * FROM (
    SELECT taxon_concept_id, full_name, matched_taxon_concept_id, matched_name,
    CASE
      WHEN POSITION(matched_name_segment IN UPPER(matched_name)) = 1 THEN UPPER(matched_name)
      ELSE matched_name_segment
    END
    FROM (
      SELECT *
      FROM scientific_names_segmented
      UNION
      SELECT *
      FROM synonyms_segmented
      UNION
      SELECT *
      FROM common_names_segmented
    ) all_names_segmented
  ) all_names_segmented_no_prefixes
  WHERE LENGTH(matched_name_segment) >= 3
), taxa_with_visibility_flags AS (
  SELECT taxon_concepts.id,
    CASE
    WHEN taxonomies.name = 'CITES_EU' THEN TRUE
    ELSE FALSE
    END AS taxonomy_is_cites_eu,
    name_status,
    ranks.name AS rank_name,
    ranks.display_name_en AS rank_display_name_en,
    ranks.display_name_es AS rank_display_name_es,
    ranks.display_name_fr AS rank_display_name_fr,
    ranks.taxonomic_position AS rank_order,
    taxon_concepts.taxonomic_position,
    CASE
      WHEN
        name_status = 'A'
        AND (
          ranks.name != 'SUBSPECIES'
          AND ranks.name != 'VARIETY'
          OR taxonomies.name = 'CITES_EU'
          AND (
            (listing->'cites_historically_listed')::BOOLEAN
            OR (listing->'eu_historically_listed')::BOOLEAN
          )
          OR taxonomies.name = 'CMS'
          AND (listing->'cms_historically_listed')::BOOLEAN
        )
      THEN TRUE
      ELSE FALSE
    END AS show_in_species_plus_ac,
    CASE
      WHEN
        name_status = 'A'
        AND (
          ranks.name != 'SUBSPECIES'
          AND ranks.name != 'VARIETY'
          OR (listing->'cites_show')::BOOLEAN
        )
      THEN TRUE
      ELSE FALSE
    END AS show_in_checklist_ac,
    CASE
      WHEN
        taxonomies.name = 'CITES_EU'
        AND ARRAY['A', 'H', 'N']::VARCHAR[] && ARRAY[name_status]
      THEN TRUE
      ELSE FALSE
    END AS show_in_trade_ac,
    CASE
      WHEN
        taxonomies.name = 'CITES_EU'
        AND ARRAY['A', 'H', 'N', 'T']::VARCHAR[] && ARRAY[name_status]
      THEN TRUE
      ELSE FALSE
    END AS show_in_trade_internal_ac
  FROM taxon_concepts
  JOIN ranks ON ranks.id = rank_id
  JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
)
SELECT
  t1.*,
  matched_name_segment AS name_for_matching,
  matched_taxon_concept_id AS matched_id,
  matched_name,
  full_name
FROM taxa_with_visibility_flags t1
JOIN all_names_segmented_cleaned t2
ON t1.id = t2.taxon_concept_id
WHERE LENGTH(matched_name_segment) >= 3;
