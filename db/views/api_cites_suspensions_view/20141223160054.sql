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
  trade_restrictions.start_date,
  trade_restrictions.end_date,
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
  trade_restrictions.start_notification_id,
  ROW_TO_JSON(
    ROW(
      events.name,
      events.effective_at,
      events.url
    )::api_event
  ) AS start_notification,
  trade_restrictions.end_notification_id,
  trade_restrictions.nomenclature_note_en,
  trade_restrictions.nomenclature_note_fr,
  trade_restrictions.nomenclature_note_es
FROM trade_restrictions
JOIN geo_entities ON geo_entities.id = trade_restrictions.geo_entity_id
JOIN geo_entity_types ON geo_entities.geo_entity_type_id = geo_entity_types.id
JOIN events ON events.id = trade_restrictions.start_notification_id
  AND events.type IN ('CitesSuspensionNotification')
LEFT JOIN taxon_concepts ON taxon_concepts.id = trade_restrictions.taxon_concept_id
WHERE trade_restrictions.type IN ('CitesSuspension');