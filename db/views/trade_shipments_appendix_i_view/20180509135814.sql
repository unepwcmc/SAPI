SELECT DISTINCT ts.*, s.code AS source, p.code AS purpose, t.code AS term, u.code AS unit, e.iso_code2 AS exporter, i.iso_code2 AS importer, o.iso_code2 AS origin
FROM trade_shipments_with_taxa_view ts
INNER JOIN trade_codes s ON ts.source_id = s.id
INNER JOIN trade_codes p ON ts.purpose_id = p.id
LEFT OUTER JOIN trade_codes t ON ts.term_id = t.id
LEFT OUTER JOIN trade_codes u ON ts.unit_id = u.id
LEFT OUTER JOIN geo_entities e ON ts.exporter_id = e.id
LEFT OUTER JOIN geo_entities i ON ts.importer_id = i.id
LEFT OUTER JOIN geo_entities o ON ts.country_of_origin_id = o.id
WHERE ts.appendix = 'I'
  AND p.type = 'Purpose'
  AND p.code = 'T'
  AND s.type = 'Source'
  AND s.code = 'W'
