SELECT
  tr.*,
  ROW_TO_JSON(
    ROW(
      geo_entities.iso_code2,
      geo_entities.name_en,
      geo_entity_types.name
    )::api_geo_entity
  ) AS geo_entity_en,
  ROW_TO_JSON(
    ROW(
      geo_entities.iso_code2,
      geo_entities.name_es,
      geo_entity_types.name
    )::api_geo_entity
  ) AS geo_entity_es,
  ROW_TO_JSON(
    ROW(
      geo_entities.iso_code2,
      geo_entities.name_fr,
      geo_entity_types.name
    )::api_geo_entity
  ) AS geo_entity_fr,
  ROW_TO_JSON(
    ROW(
      events.name,
      events.effective_at::DATE,
      events.url
    )::api_event
  ) AS start_notification
FROM (
  SELECT * FROM (
    SELECT tr.*,
      CASE
      WHEN tr.taxon_concept_id IS NOT NULL THEN
        ROW_TO_JSON(
          ROW(
            tr.taxon_concept_id,
            taxon_concepts.full_name,
            taxon_concepts.author_year,
            taxon_concepts.data->'rank_name'
          )::api_taxon_concept
        )
      ELSE
        NULL::JSON
      END AS taxon_concept
    FROM (
      SELECT
        tr.id,
        tr.type,
        tr.taxon_concept_id,
        tr.notes,
        tr.start_date::DATE,
        tr.end_date::DATE,
        tr.is_current,
        tr.geo_entity_id,
        tr.applies_to_import,
        tr.start_notification_id,
        tr.end_notification_id,
        tr.nomenclature_note_en,
        tr.nomenclature_note_fr,
        tr.nomenclature_note_es
      FROM trade_restrictions tr
      WHERE tr.type IN ('CitesSuspension')
    ) tr
    LEFT JOIN taxon_concepts ON taxon_concepts.id = tr.taxon_concept_id
  ) cites_suspensions_without_taxon_concept
) tr
LEFT JOIN geo_entities ON geo_entities.id = tr.geo_entity_id
LEFT JOIN geo_entity_types ON geo_entities.geo_entity_type_id = geo_entity_types.id
JOIN events ON events.id = tr.start_notification_id
  AND events.type IN ('CitesSuspensionNotification');
