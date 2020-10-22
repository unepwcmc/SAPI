SELECT ts.*,
       ts.term_quantity_unit[1] AS term_id,
       CASE WHEN ts.reported_by_exporter IS FALSE
         THEN ts.term_quantity_unit[2]
         ELSE NULL
       END AS importer_reported_quantity,
       CASE WHEN ts.reported_by_exporter IS TRUE
         THEN ts.term_quantity_unit[2]
         ELSE NULL
       END AS exporter_reported_quantity,
       ts.term_quantity_unit[3] AS unit_id,
       terms.code AS term_code,
       terms.name_en AS term,
       units.code AS unit_code,
       units.name_en AS unit
FROM trade_plus_formatted_data_view ts
LEFT OUTER JOIN trade_codes terms ON terms.id = ts.term_quantity_unit[1]
LEFT OUTER JOIN trade_codes units ON units.id = ts.term_quantity_unit[3]
