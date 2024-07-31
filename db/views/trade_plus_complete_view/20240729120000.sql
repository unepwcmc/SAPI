SELECT
  ts.*,
  exporters.id          AS exporter_id,
  exporters.iso_code2   AS exporter_iso,
  exporters.name_en     AS exporter_en,
  exporters.name_es     AS exporter_es,
  exporters.name_fr     AS exporter_fr,
  importers.id          AS importer_id,
  importers.iso_code2   AS importer_iso,
  importers.name_en     AS importer_en,
  importers.name_es     AS importer_es,
  importers.name_fr     AS importer_fr,
  origins.id            AS origin_id,
  origins.iso_code2     AS origin_iso,
  origins.name_en       AS origin_en,
  origins.name_es       AS origin_es,
  origins.name_fr       AS origin_fr,
  purposes.name_en      AS purpose_en,
  purposes.name_es      AS purpose_es,
  purposes.name_fr      AS purpose_fr,
  purposes.code         AS purpose_code,
  sources.name_en       AS source_en,
  sources.name_es       AS source_es,
  sources.name_fr       AS source_fr,
  sources.code          AS source_code,
  ranks.id              AS rank_id,
  ranks.display_name_en AS rank_name_en,
  ranks.display_name_es AS rank_name_es,
  ranks.display_name_fr AS rank_name_fr,

  CASE WHEN ts.reported_by_exporter IS FALSE THEN
    CASE
      WHEN ts.term_quantity_modifier = '*' THEN
        CASE
          WHEN unit_quantity_modifier = '*' THEN ts.quantity * ts.term_modifier_value * ts.unit_modifier_value
          WHEN unit_quantity_modifier = '/' THEN ts.quantity * ts.term_modifier_value / ts.unit_modifier_value
          ELSE ts.quantity * ts.term_modifier_value
        END
      WHEN ts.term_quantity_modifier = '/' THEN
        CASE
          WHEN unit_quantity_modifier = '*' THEN ts.quantity / ts.term_modifier_value * ts.unit_modifier_value
          WHEN unit_quantity_modifier = '/' THEN ts.quantity / ts.term_modifier_value / ts.unit_modifier_value
          ELSE ts.quantity / ts.term_modifier_value
        END
      ELSE
        CASE
          WHEN unit_quantity_modifier = '*' THEN ts.quantity * ts.unit_modifier_value
          WHEN unit_quantity_modifier = '/' THEN ts.quantity / ts.unit_modifier_value
          ELSE ts.quantity
        END
      END
    ELSE NULL
  END AS importer_reported_quantity,

  CASE WHEN ts.reported_by_exporter IS TRUE THEN
    CASE
      WHEN ts.term_quantity_modifier = '*' THEN
        CASE
          WHEN unit_quantity_modifier = '*' THEN ts.quantity * ts.term_modifier_value * ts.unit_modifier_value
          WHEN unit_quantity_modifier = '/' THEN ts.quantity * ts.term_modifier_value / ts.unit_modifier_value
          ELSE ts.quantity * term_modifier_value
        END
      WHEN ts.term_quantity_modifier = '/' THEN
        CASE
          WHEN unit_quantity_modifier = '*' THEN ts.quantity / ts.term_modifier_value * ts.unit_modifier_value
          WHEN unit_quantity_modifier = '/' THEN ts.quantity / ts.term_modifier_value / ts.unit_modifier_value
          ELSE ts.quantity / ts.term_modifier_value
        END
      ELSE
        CASE
          WHEN unit_quantity_modifier = '*' THEN ts.quantity * ts.unit_modifier_value
          WHEN unit_quantity_modifier = '/' THEN ts.quantity / ts.unit_modifier_value
          ELSE ts.quantity
        END
      END
    ELSE NULL
  END AS exporter_reported_quantity
FROM trade_plus_formatted_data_final_view ts
LEFT OUTER JOIN trade_codes terms ON ts.term_id = terms.id
LEFT OUTER JOIN trade_codes units ON ts.unit_id = units.id
LEFT OUTER JOIN trade_codes sources ON ts.source_id = sources.id
LEFT OUTER JOIN trade_codes purposes ON ts.purpose_id = purposes.id
INNER JOIN ranks ON ranks.id = ts.taxon_concept_rank_id
LEFT OUTER JOIN geo_entities exporters ON ts.china_exporter_id = exporters.id
LEFT OUTER JOIN geo_entities importers ON ts.china_importer_id = importers.id
LEFT OUTER JOIN geo_entities origins ON ts.china_origin_id = origins.id
