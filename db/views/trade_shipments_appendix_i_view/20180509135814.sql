SELECT DISTINCT ts.*
FROM trade_shipments_with_taxa_view ts
INNER JOIN trade_codes s ON ts.source_id = s.id
INNER JOIN trade_codes p ON ts.purpose_id = p.id
INNER JOIN listing_changes lc ON ts.taxon_concept_id = lc.taxon_concept_id
INNER JOIN species_listings sl ON lc.species_listing_id = sl.id
WHERE ts.appendix = 'I'
  AND lc.is_current
  AND ts.year >= to_char(lc.effective_at, 'YYYY')::int
  AND p.type = 'Purpose'
  AND p.code = 'T'
  AND s.type = 'Source'
  AND s.code = 'W'
