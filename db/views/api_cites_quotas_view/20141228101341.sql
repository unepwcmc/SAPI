WITH cites_quotas AS (
  SELECT
    tr.id,
    tr.type,
    tr.taxon_concept_id,
    tr.notes,
    tr.url,
    tr.start_date,
    tr.publication_date::DATE,
    tr.is_current,
    tr.geo_entity_id,
    tr.unit_id,
    CASE WHEN tr.quota = -1 THEN NULL ELSE tr.quota END AS quota,
    tr.public_display,
    tr.nomenclature_note_en,
    tr.nomenclature_note_fr,
    tr.nomenclature_note_es
  FROM trade_restrictions tr
  WHERE tr.type IN ('Quota')
), cites_quotas_with_taxon_concept AS (
  SELECT tr.*,
  ROW_TO_JSON(
    ROW(
      taxon_concept_id,
      taxon_concepts.full_name,
      taxon_concepts.author_year,
      taxon_concepts.data->'rank_name'
    )::api_taxon_concept
  ) AS taxon_concept,
  ARRAY[]::INT[] AS matching_taxon_concept_ids
  FROM cites_quotas tr
  JOIN taxon_concepts ON taxon_concepts.id = tr.taxon_concept_id
  WHERE taxon_concept_id IS NOT NULL
), cites_quotas_without_taxon_concept AS (
  SELECT tr.*,
    NULL::JSON AS taxon_concept,
    ARRAY_AGG_NOTNULL(
      distributions.taxon_concept_id
    ) AS matching_taxon_concept_ids
  FROM cites_quotas tr
  JOIN distributions ON distributions.geo_entity_id = tr.geo_entity_id
  WHERE tr.taxon_concept_id IS NULL
  GROUP BY
    tr.id,
    tr.type,
    tr.taxon_concept_id,
    tr.notes,
    tr.url,
    tr.start_date,
    tr.publication_date,
    tr.is_current,
    tr.geo_entity_id,
    tr.unit_id,
    tr.quota,
    tr.public_display,
    tr.nomenclature_note_en,
    tr.nomenclature_note_fr,
    tr.nomenclature_note_es
), all_cites_quotas AS (
  SELECT * FROM cites_quotas_with_taxon_concept
  UNION ALL
  SELECT * FROM cites_quotas_without_taxon_concept
)
SELECT tr. *,
  ROW_TO_JSON(
    ROW(
      geo_entities.id,
      geo_entities.iso_code2,
      geo_entities.name_en,
      geo_entity_types.name
    )::api_geo_entity
  ) AS geo_entity_en,
  ROW_TO_JSON(
    ROW(
      geo_entities.id,
      geo_entities.iso_code2,
      geo_entities.name_es,
      geo_entity_types.name
    )::api_geo_entity
  ) AS geo_entity_es,
  ROW_TO_JSON(
    ROW(
      geo_entities.id,
      geo_entities.iso_code2,
      geo_entities.name_fr,
      geo_entity_types.name
    )::api_geo_entity
  ) AS geo_entity_fr,
  CASE
    WHEN unit_id IS NULL THEN NULL::JSON
    ELSE
      ROW_TO_JSON(
        ROW(
          units.id,
          units.code,
          units.name_en
        )::api_trade_code
      )
  END AS unit_en,
  CASE
    WHEN unit_id IS NULL THEN NULL::JSON
    ELSE
      ROW_TO_JSON(
        ROW(
          units.id,
          units.code,
          units.name_es
        )::api_trade_code
      )
  END AS unit_es,
  CASE
    WHEN unit_id IS NULL THEN NULL::JSON
    ELSE
      ROW_TO_JSON(
        ROW(
          units.id,
          units.code,
          units.name_fr
        )::api_trade_code
      )
  END AS unit_fr
FROM all_cites_quotas tr
JOIN geo_entities ON geo_entities.id = tr.geo_entity_id
JOIN geo_entity_types ON geo_entities.geo_entity_type_id = geo_entity_types.id
LEFT JOIN trade_codes units ON units.id = tr.unit_id AND units.type = 'Unit';
