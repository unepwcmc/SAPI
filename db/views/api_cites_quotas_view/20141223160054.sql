SELECT
  trade_restrictions.type,
  trade_restrictions.taxon_concept_id,
  ROW_TO_JSON(
    ROW(
      taxon_concept_id,
      taxon_concepts.full_name,
      taxon_concepts.author_year,
      taxon_concepts.data->'rank_name'
    )::api_taxon_concept
  ) AS taxon_concept,
  trade_restrictions.notes,
  trade_restrictions.url,
  trade_restrictions.start_date,
  trade_restrictions.publication_date,
  trade_restrictions.is_current,
  trade_restrictions.geo_entity_id,
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
  trade_restrictions.unit_id,
  ROW_TO_JSON(
    ROW(
      units.id,
      units.code,
      units.name_en
    )::api_trade_code
  ) AS unit_en,
  ROW_TO_JSON(
    ROW(
      units.id,
      units.code,
      units.name_es
    )::api_trade_code
  ) AS unit_es,
  ROW_TO_JSON(
    ROW(
      units.id,
      units.code,
      units.name_fr
    )::api_trade_code
  ) AS unit_fr,
  CASE WHEN trade_restrictions.quota = -1 THEN NULL ELSE trade_restrictions.quota END AS quota,
  trade_restrictions.public_display,
  trade_restrictions.nomenclature_note_en,
  trade_restrictions.nomenclature_note_fr,
  trade_restrictions.nomenclature_note_es
  FROM trade_restrictions
  JOIN geo_entities ON geo_entities.id = trade_restrictions.geo_entity_id
  JOIN geo_entity_types ON geo_entities.geo_entity_type_id = geo_entity_types.id
  LEFT JOIN taxon_concepts ON taxon_concepts.id = trade_restrictions.taxon_concept_id
  LEFT JOIN trade_codes units ON units.id = trade_restrictions.unit_id AND units.type = 'Unit'
  WHERE trade_restrictions.type IN ('Quota');
