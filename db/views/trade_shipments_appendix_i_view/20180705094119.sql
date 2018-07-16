SELECT ts.id, ts.year, ts.appendix, ts.taxon_concept_id,
       ts.taxon_concept_full_name AS taxon,
       ts.taxon_concept_class_name AS class,
       ts.taxon_concept_order_name AS order,
       ts.taxon_concept_family_name AS family,
       ts.taxon_concept_genus_name AS genus,
       terms.name_en AS term,
       CASE WHEN ts.reported_by_exporter IS FALSE THEN ts.quantity
            ELSE NULL
       END AS importer_reported_quantity,
       CASE WHEN ts.reported_by_exporter IS TRUE THEN ts.quantity
            ELSE NULL
       END AS exporter_reported_quantity,
       units.name_en AS unit,
       exporters.iso_code2 AS exporter_iso,
       exporters.name_en AS exporter,
       importers.iso_code2 AS importer_iso,
       importers.name_en AS importer,
       origins.iso_code2 AS origin,
       purposes.name_en AS purpose, sources.name_en AS source, ts.import_permit_number AS import_permit,
       ts.export_permit_number AS export_permit, ts.origin_permit_number AS origin_permit,
       ranks.name AS compliance_type_taxonomic_rank,
       'AppendixI' AS issue_type
FROM trade_shipments_with_taxa_view ts
INNER JOIN trade_codes sources ON ts.source_id = sources.id
INNER JOIN trade_codes purposes ON ts.purpose_id = purposes.id
INNER JOIN ranks ON ranks.id = ts.taxon_concept_rank_id
LEFT OUTER JOIN trade_codes terms ON ts.term_id = terms.id
LEFT OUTER JOIN trade_codes units ON ts.unit_id = units.id
LEFT OUTER JOIN geo_entities exporters ON ts.exporter_id = exporters.id
LEFT OUTER JOIN geo_entities importers ON ts.importer_id = importers.id
LEFT OUTER JOIN geo_entities origins ON ts.country_of_origin_id = origins.id
WHERE ts.appendix = 'I'
  AND purposes.type = 'Purpose'
  AND purposes.code = 'T'
  AND sources.type = 'Source'
  AND sources.code = 'W'
