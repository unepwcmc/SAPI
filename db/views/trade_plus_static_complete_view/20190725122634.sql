SELECT DISTINCT *
FROM (
  SELECT ts.id,
         ts.year,
         ts.appendix,
         listings.id AS appendix_id,
         ts.taxon_id,
         ts.taxon_name AS taxon_name,
         ts.kingdom_name AS kingdom_name,
         ts.phylum_name AS phylum_name,
         ts.group_name AS group_name,
         ts.class_name AS class_name,
         ts.order_name AS order_name,
         ts.family_name AS family_name,
         ts.genus_name AS genus_name,
         terms.id AS term_id,
         ts.term_converted AS term,
         ts.importer_reported_quantity AS importer_reported_quantity,
         ts.exporter_reported_quantity AS exporter_reported_quantity,
         units.id AS unit_id,
         ts.unit_converted AS unit,
         exporters.id AS exporter_id,
         exporters.iso_code2 AS exporter_iso,
         exporters.name_en AS exporter,
         importers.id AS importer_id,
         importers.iso_code2 AS importer_iso,
         importers.name_en AS importer,
         origins.id AS origin_id,
         origins.iso_code2 AS origin_iso,
         origins.name_en AS origin,
         purposes.id AS purpose_id,
         purposes.name_en AS purpose,
         sources.id AS source_id,
         sources.name_en AS source
  FROM trade_plus_static ts
  INNER JOIN species_listings listings ON listings.abbreviation = ts.appendix
  LEFT OUTER JOIN trade_codes sources ON ts.source = sources.code AND sources.type = 'Source'
  LEFT OUTER JOIN trade_codes purposes ON ts.purpose = purposes.code AND purposes.type = 'Purpose'
  LEFT OUTER JOIN trade_codes terms ON ts.term_converted = terms.name_en AND terms.type = 'Term'
  LEFT OUTER JOIN trade_codes units ON ts.unit_converted = units.name_en AND units.type = 'Unit'
  LEFT OUTER JOIN geo_entities exporters ON ts.exporter_iso = exporters.iso_code2
  LEFT OUTER JOIN geo_entities importers ON ts.importer_iso = importers.iso_code2
  LEFT OUTER JOIN geo_entities origins ON ts.origin_iso = origins.iso_code2
  WHERE ts.appendix != 'N'
  AND listings.designation_id = 1
  )
  AS s
