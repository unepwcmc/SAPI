-- Fetch all shipments where taxon concepts are specified in CITES Suspension.
-- It considers also the geo_entity if specified in the Suspension as well as sources and purposes if any.
(
  SELECT ts.*, exporters.iso_code2 AS exporter, importers.iso_code2 AS importer,
  tr_tc.id AS suspension_id, tr_tc.is_current, tr_tc.start_date, tr_tc.end_date, tr_tc.geo_entity_id, tr_tc.quota,
  start_notifications.name AS start_notification, end_notifications.name AS end_notification,
  tr_tc.publication_date, tr_tc.notes, tr_tc.type, tr_tc.taxon_concept_id AS suspension_taxon_concept_id,
  tr_tc.original_id, tr_tc.internal_notes, tr_tc.applies_to_import, suspension_countries.iso_code2 AS country,
  sources.code AS source, purposes.code AS purpose
  FROM trade_shipments ts
  INNER JOIN trade_restrictions tr_tc ON tr_tc.taxon_concept_id = ts.taxon_concept_id
  INNER JOIN events start_notifications ON tr_tc.start_notification_id  = start_notifications.id
  INNER JOIN geo_entities importers ON ts.importer_id = importers.id
  INNER JOIN geo_entities exporters ON ts.exporter_id = exporters.id
  LEFT OUTER JOIN geo_entities suspension_countries ON tr_tc.geo_entity_id = suspension_countries.id
  LEFT OUTER JOIN events end_notifications ON tr_tc.end_notification_id = end_notifications.id
  LEFT OUTER JOIN trade_restriction_sources tr_s ON tr_tc.id = tr_s.trade_restriction_id
  LEFT OUTER JOIN trade_restriction_purposes tr_p ON tr_tc.id = tr_p.trade_restriction_id
  LEFT OUTER JOIN trade_codes sources ON sources.id = tr_s.source_id
  LEFT OUTER JOIN trade_codes purposes ON purposes.id = tr_p.purpose_id
  WHERE tr_tc.type = 'CitesSuspension' AND
  start_notifications.type = 'CitesSuspensionNotification' AND
  end_notifications.type = 'CitesSuspensionNotification' AND
  ts.year BETWEEN EXTRACT(YEAR FROM tr_tc.start_date) AND EXTRACT(YEAR FROM tr_tc.end_date) AND
  (tr_tc.geo_entity_id IS NULL OR (tr_tc.geo_entity_id = ts.exporter_id OR tr_tc.geo_entity_id = ts.importer_id AND tr_tc.applies_to_import)) AND
  (tr_s.source_id = ts.source_id OR tr_s.id IS NULL) AND (tr_p.purpose_id = ts.purpose_id OR tr_p.id IS NULL)
)

UNION

-- Fetch all shipments where geo entities are specified in CITES Suspension, both for importer and exporter.
-- It considers also taxon concepts if specified in the Suspension as well as sources and purposes if any.

(
  SELECT ts.*, exporters.iso_code2 AS exporter, importers.iso_code2 AS importer,
  tr_ge.id AS suspension_id, tr_ge.is_current, tr_ge.start_date, tr_ge.end_date, tr_ge.geo_entity_id, tr_ge.quota,
  start_notifications.name AS start_notification, end_notifications.name AS end_notification,
  tr_ge.publication_date, tr_ge.notes, tr_ge.type, tr_ge.taxon_concept_id AS suspension_taxon_concept_id,
  tr_ge.original_id, tr_ge.internal_notes, tr_ge.applies_to_import, suspension_countries.iso_code2 AS country,
  sources.code AS source, purposes.code AS purpose
  FROM trade_shipments ts
  INNER JOIN trade_restrictions tr_ge ON tr_ge.geo_entity_id = ts.exporter_id OR (tr_ge.geo_entity_id = ts.importer_id AND tr_ge.applies_to_import)
  INNER JOIN events start_notifications ON tr_ge.start_notification_id  = start_notifications.id
  INNER JOIN geo_entities importers ON ts.importer_id = importers.id
  INNER JOIN geo_entities exporters ON ts.exporter_id = exporters.id
  LEFT OUTER JOIN geo_entities suspension_countries ON tr_ge.geo_entity_id = suspension_countries.id
  LEFT OUTER JOIN events end_notifications ON tr_ge.end_notification_id = end_notifications.id
  LEFT OUTER JOIN trade_restriction_sources tr_s ON tr_ge.id = tr_s.trade_restriction_id
  LEFT OUTER JOIN trade_restriction_purposes tr_p ON tr_ge.id = tr_p.trade_restriction_id
  LEFT OUTER JOIN trade_codes sources ON sources.id = tr_s.source_id
  LEFT OUTER JOIN trade_codes purposes ON purposes.id = tr_p.purpose_id
  WHERE tr_ge.type = 'CitesSuspension' AND
  start_notifications.type = 'CitesSuspensionNotification' AND
  end_notifications.type = 'CitesSuspensionNotification' AND
  (tr_ge.taxon_concept_id IS NULL OR tr_ge.taxon_concept_id = ts.taxon_concept_id) AND
  ts.year BETWEEN EXTRACT(YEAR FROM tr_ge.start_date) AND EXTRACT(YEAR FROM tr_ge.end_date) AND
  (tr_s.source_id = ts.source_id OR tr_s.id IS NULL) AND (tr_p.purpose_id = ts.purpose_id OR tr_p.id IS NULL)
)
