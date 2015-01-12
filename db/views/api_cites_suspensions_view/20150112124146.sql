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
    ROW_TO_JSON(
      ROW(
        taxon_concept_id,
        taxon_concepts.full_name,
        taxon_concepts.author_year,
        taxon_concepts.data->'rank_name'
      )::api_taxon_concept
    ) AS taxon_concept,
    ARRAY[]::INT[] AS matching_taxon_concept_ids
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
        tr.start_notification_id,
        tr.end_notification_id,
        tr.nomenclature_note_en,
        tr.nomenclature_note_fr,
        tr.nomenclature_note_es
      FROM trade_restrictions tr
      WHERE tr.type IN ('CitesSuspension')
    ) tr
    JOIN taxon_concepts ON taxon_concepts.id = tr.taxon_concept_id
    WHERE taxon_concept_id IS NOT NULL
  ) cites_suspensions_with_taxon_concept

  UNION ALL

  SELECT * FROM (
    SELECT tr.*,
      NULL::JSON AS taxon_concept,
      ARRAY_AGG_NOTNULL(
        distributions.taxon_concept_id
      ) AS matching_taxon_concept_ids
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
        tr.start_notification_id,
        tr.end_notification_id,
        tr.nomenclature_note_en,
        tr.nomenclature_note_fr,
        tr.nomenclature_note_es
      FROM trade_restrictions tr
      WHERE tr.type IN ('CitesSuspension')
    ) tr
    JOIN distributions ON distributions.geo_entity_id = tr.geo_entity_id
    WHERE tr.taxon_concept_id IS NULL
    GROUP BY
      tr.id,
      tr.type,
      tr.taxon_concept_id,
      tr.notes,
      tr.start_date,
      tr.end_date,
      tr.is_current,
      tr.geo_entity_id,
      tr.start_notification_id,
      tr.end_notification_id,
      tr.nomenclature_note_en,
      tr.nomenclature_note_fr,
      tr.nomenclature_note_es
  ) cites_suspensions_without_taxon_concept
) tr
JOIN geo_entities ON geo_entities.id = tr.geo_entity_id
JOIN geo_entity_types ON geo_entities.geo_entity_type_id = geo_entity_types.id
JOIN events ON events.id = tr.start_notification_id
  AND events.type IN ('CitesSuspensionNotification');
