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
), unlisted_subspecies_segmented(taxon_concept_id, full_name, matched_taxon_concept_id, matched_name, matched_name_segment) AS (
  SELECT
    parents.id,
    parents.full_name,
    taxon_concepts.id,
    taxon_concepts.full_name,
    UPPER(REGEXP_SPLIT_TO_TABLE(taxon_concepts.full_name, ' '))
  FROM taxon_concepts
  JOIN ranks ON ranks.id = taxon_concepts.rank_id
  AND ranks.name IN ('SUBSPECIES', 'VARIETY')
  JOIN taxon_concepts parents
  ON parents.id = taxon_concepts.parent_id
  WHERE taxon_concepts.name_status NOT IN ('S', 'T', 'N')
  AND parents.name_status = 'A'

  EXCEPT

  SELECT
    parents.id,
    parents.full_name,
    taxon_concepts.id,
    taxon_concepts.full_name,
    UPPER(REGEXP_SPLIT_TO_TABLE(taxon_concepts.full_name, ' '))
  FROM taxon_concepts
  JOIN ranks ON ranks.id = taxon_concepts.rank_id
  AND ranks.name IN ('SUBSPECIES') -- VARIETY not here on purpose
  JOIN taxon_concepts parents
  ON parents.id = taxon_concepts.parent_id
  JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
  WHERE taxon_concepts.name_status NOT IN ('S', 'T', 'N')
  AND parents.name_status = 'A'
  AND CASE
    WHEN taxonomies.name = 'CMS'
    THEN (taxon_concepts.listing->'cms_historically_listed')::BOOLEAN
    ELSE (taxon_concepts.listing->'cites_historically_listed')::BOOLEAN
    OR (taxon_concepts.listing->'eu_historically_listed')::BOOLEAN
  END
), taxon_common_names AS (
  SELECT
    taxon_commons.*,
    common_names.name
  FROM taxon_commons
  JOIN common_names
  ON common_names.id = taxon_commons.common_name_id
  JOIN languages
  ON languages.id = common_names.language_id
  AND languages.iso_code1 IN ('EN', 'ES', 'FR')
), common_names_segmented(taxon_concept_id, full_name, matched_taxon_concept_id, matched_name, matched_name_segment) AS (
  SELECT
    taxon_concept_id,
    taxon_concepts.full_name,
    NULL::INT,
    taxon_common_names.name,
    UPPER(REGEXP_SPLIT_TO_TABLE(taxon_common_names.name, E'\\s|'''))
  FROM taxon_common_names
  JOIN taxon_concepts
  ON taxon_common_names.taxon_concept_id = taxon_concepts.id
), taxon_common_names_dehyphenated AS (
  SELECT
    taxon_concept_id,
    taxon_concepts.full_name,
    NULL::INT,
    taxon_common_names.name,
    UPPER(REPLACE(taxon_common_names.name, '-', ' '))
  FROM taxon_common_names
  JOIN taxon_concepts
  ON taxon_common_names.taxon_concept_id = taxon_concepts.id
  WHERE STRPOS(taxon_common_names.name, '-') > 0
), common_names_segmented_dehyphenated AS (
  SELECT taxon_concept_id, full_name, matched_taxon_concept_id, matched_name, matched_name_segment
  FROM common_names_segmented
  UNION
  SELECT taxon_concept_id, full_name, matched_taxon_concept_id, matched_name, REGEXP_SPLIT_TO_TABLE(matched_name_segment, E'-')
  FROM common_names_segmented
  WHERE STRPOS(matched_name_segment, '-') > 0
  UNION
  SELECT * FROM taxon_common_names_dehyphenated
), all_names_segmented_cleaned AS (
  SELECT * FROM (
    SELECT taxon_concept_id, full_name, matched_taxon_concept_id, matched_name,
    CASE
      WHEN POSITION(matched_name_segment IN
        UPPER(matched_name)
      ) = 1 THEN UPPER(matched_name)
      ELSE matched_name_segment
    END, type_of_match
    FROM (
      SELECT *, 'SELF' AS type_of_match
      FROM scientific_names_segmented
      UNION
      SELECT *, 'SYNONYM'
      FROM synonyms_segmented
      UNION
      SELECT *, 'SUBSPECIES'
      FROM unlisted_subspecies_segmented
      UNION
      SELECT *, 'COMMON_NAME'
      FROM common_names_segmented_dehyphenated
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
  full_name,
  type_of_match
FROM taxa_with_visibility_flags t1
JOIN all_names_segmented_cleaned t2
ON t1.id = t2.taxon_concept_id
WHERE LENGTH(matched_name_segment) >= 3;
