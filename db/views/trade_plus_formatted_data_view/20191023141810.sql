SELECT DISTINCT *
FROM(
    SELECT ts.*,
           ts.term_quantity_unit[1] AS term_code,
           CASE WHEN ts.reported_by_exporter IS FALSE
             THEN ts.term_quantity_unit[2]
             ELSE NULL
           END AS importer_reported_quantity,
           CASE WHEN ts.reported_by_exporter IS TRUE
             THEN ts.term_quantity_unit[2]
             ELSE NULL
           END AS exporter_reported_quantity,
           ts.term_quantity_unit[3] AS unit_code,
           terms.id AS term_id,
           terms.name_en AS term,
           units.id AS unit_id,
           units.name_en AS unit
    FROM trade_plus_with_taxa_view ts
    LEFT OUTER JOIN trade_codes terms ON terms.code = ts.term_quantity_unit[1] AND terms.type = 'Term'
    LEFT OUTER JOIN trade_codes units ON units.code = ts.term_quantity_unit[3] AND units.type = 'Unit'
  ) AS s
