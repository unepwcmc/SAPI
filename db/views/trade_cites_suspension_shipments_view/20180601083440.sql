SELECT *
FROM(
  -- Fetch all shipments where taxon concepts are specified in CITES Suspension.
  -- It considers also the geo_entity if specified in the Suspension as well as sources and purposes if any.
  (
    SELECT ts.id, ts.year, ts.appendix,
           ts.taxon_concept_full_name AS taxon,
           ts.taxon_concept_class_name AS class,
           ts.taxon_concept_order_name AS order,
           ts.taxon_concept_family_name AS family,
           ts.taxon_concept_genus_name AS genus,
           terms.name_en AS term,
           CASE WHEN tr_tc.applies_to_import IS TRUE THEN ts.quantity
                ELSE NULL
           END AS importer_reported_quantity,
           CASE WHEN tr_tc.applies_to_import IS FALSE THEN ts.quantity
                ELSE NULL
           END AS exporter_reported_quantity,
           units.name_en AS unit, exporters.iso_code2 AS exporter, importers.iso_code2 AS importer, NULL AS origin,
           purposes.name_en AS purpose, sources.name_en AS source, ts.import_permit_number AS import_permit,
           ts.export_permit_number AS export_permit, ts.origin_permit_number AS origin_permit, 'Suspension' AS issue_type,
           start_notifications.subtype AS details_of_compliance_issue,
           start_notifications.effective_at AS compliance_type_start_date,
           ts.taxon_concept_full_name AS compliance_type_taxon,
           ranks.name AS compliance_type_taxonomic_rank,
           end_notifications.effective_at AS compliance_type_end_date,
           start_notifications.name AS suspension_start_notification, end_notifications.name AS suspension_end_notification,
           tr_tc.notes AS notes
    FROM trade_shipments_with_taxa_view ts
    INNER JOIN trade_restrictions tr_tc ON tr_tc.taxon_concept_id = ts.taxon_concept_id
    INNER JOIN events start_notifications ON tr_tc.start_notification_id  = start_notifications.id
    INNER JOIN geo_entities importers ON ts.importer_id = importers.id
    INNER JOIN geo_entities exporters ON ts.exporter_id = exporters.id
    INNER JOIN ranks ON ranks.id = ts.taxon_concept_rank_id
    LEFT OUTER JOIN geo_entities suspension_countries ON tr_tc.geo_entity_id = suspension_countries.id
    LEFT OUTER JOIN events end_notifications ON tr_tc.end_notification_id = end_notifications.id
    LEFT OUTER JOIN trade_restriction_sources tr_s ON tr_tc.id = tr_s.trade_restriction_id
    LEFT OUTER JOIN trade_restriction_purposes tr_p ON tr_tc.id = tr_p.trade_restriction_id
    LEFT OUTER JOIN trade_codes sources ON sources.id = tr_s.source_id
    LEFT OUTER JOIN trade_codes purposes ON purposes.id = tr_p.purpose_id
    LEFT OUTER JOIN trade_codes units ON units.id = ts.unit_id
    LEFT OUTER JOIN trade_codes terms ON terms.id = ts.term_id
    WHERE tr_tc.type = 'CitesSuspension' AND
    start_notifications.type = 'CitesSuspensionNotification' AND
    end_notifications.type = 'CitesSuspensionNotification' AND
    ts.year BETWEEN EXTRACT(YEAR FROM tr_tc.start_date) AND EXTRACT(YEAR FROM tr_tc.end_date) AND
    (tr_tc.geo_entity_id IS NULL OR (tr_tc.geo_entity_id = ts.exporter_id OR tr_tc.geo_entity_id = ts.importer_id AND tr_tc.applies_to_import)) AND
    (tr_s.source_id = ts.source_id OR tr_s.id IS NULL) AND (tr_p.purpose_id = ts.purpose_id OR tr_p.id IS NULL) AND country_of_origin_id IS NULL
  )

  UNION

  -- Fetch all shipments where geo entities are specified in CITES Suspension, both for importer and exporter.
  -- It considers also taxon concepts if specified in the Suspension as well as sources and purposes if any.

  (
    SELECT ts.id, ts.year, ts.appendix,
           ts.taxon_concept_full_name AS taxon,
           ts.taxon_concept_class_name AS class,
           ts.taxon_concept_order_name AS order,
           ts.taxon_concept_family_name AS family,
           ts.taxon_concept_genus_name AS genus,
           terms.name_en AS term,
           CASE WHEN tr_ge.applies_to_import IS TRUE THEN ts.quantity
                ELSE NULL
           END AS importer_reported_quantity,
           CASE WHEN tr_ge.applies_to_import IS FALSE THEN ts.quantity
                ELSE NULL
           END AS exporter_reported_quantity,
           units.name_en AS unit, exporters.iso_code2 AS exporter, importers.iso_code2 AS importer, NULL AS origin,
           purposes.name_en AS purpose, sources.name_en AS source, ts.import_permit_number AS import_permit,
           ts.export_permit_number AS export_permit, ts.origin_permit_number AS origin_permit, 'Suspension' AS issue_type,
           start_notifications.subtype AS details_of_compliance_issue,
           start_notifications.effective_at AS compliance_type_start_date,
           ts.taxon_concept_full_name AS compliance_type_taxon,
           ranks.name AS compliance_type_taxonomic_rank,
           end_notifications.effective_at AS compliance_type_end_date,
           start_notifications.name AS suspension_start_notification, end_notifications.name AS suspension_end_notification,
           tr_ge.notes AS notes
    FROM trade_shipments_with_taxa_view ts
    INNER JOIN trade_restrictions tr_ge ON tr_ge.geo_entity_id = ts.exporter_id OR (tr_ge.geo_entity_id = ts.importer_id AND tr_ge.applies_to_import)
    INNER JOIN events start_notifications ON tr_ge.start_notification_id  = start_notifications.id
    INNER JOIN geo_entities importers ON ts.importer_id = importers.id
    INNER JOIN geo_entities exporters ON ts.exporter_id = exporters.id
    LEFT OUTER JOIN ranks ON ranks.id = ts.taxon_concept_rank_id
    LEFT OUTER JOIN geo_entities suspension_countries ON tr_ge.geo_entity_id = suspension_countries.id
    LEFT OUTER JOIN events end_notifications ON tr_ge.end_notification_id = end_notifications.id
    LEFT OUTER JOIN trade_restriction_sources tr_s ON tr_ge.id = tr_s.trade_restriction_id
    LEFT OUTER JOIN trade_restriction_purposes tr_p ON tr_ge.id = tr_p.trade_restriction_id
    LEFT OUTER JOIN trade_codes sources ON sources.id = tr_s.source_id
    LEFT OUTER JOIN trade_codes purposes ON purposes.id = tr_p.purpose_id
    LEFT OUTER JOIN trade_codes units ON units.id = ts.unit_id
    LEFT OUTER JOIN trade_codes terms ON terms.id = ts.term_id
    WHERE tr_ge.type = 'CitesSuspension' AND
    start_notifications.type = 'CitesSuspensionNotification' AND
    end_notifications.type = 'CitesSuspensionNotification' AND
    (tr_ge.taxon_concept_id IS NULL OR tr_ge.taxon_concept_id = ts.taxon_concept_id) AND
    ts.year BETWEEN EXTRACT(YEAR FROM tr_ge.start_date) AND EXTRACT(YEAR FROM tr_ge.end_date) AND
    (tr_s.source_id = ts.source_id OR tr_s.id IS NULL) AND (tr_p.purpose_id = ts.purpose_id OR tr_p.id IS NULL) AND country_of_origin_id IS NULL
  )
) AS s
ORDER BY s.year, s.class, s.order, s.family, s.genus, s.taxon, s.term
