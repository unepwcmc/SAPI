SELECT DISTINCT *
FROM (
  SELECT ts.id, ts.year, ts.appendix, ts.taxon_concept_id,
         ts.taxon_concept_author_year AS author_year,
         ts.taxon_concept_name_status AS name_status,
         ts.taxon_concept_full_name AS taxon_name,
         ts.taxon_concept_phylum_id AS phylum_id,
         ts.taxon_concept_class_id AS class_id,
         ts.taxon_concept_class_name AS class_name,
         ts.taxon_concept_order_id AS order_id,
         ts.taxon_concept_order_name AS order_name,
         ts.taxon_concept_family_id AS family_id,
         ts.taxon_concept_family_name AS family_name,
         ts.taxon_concept_genus_id AS genus_id,
         ts.taxon_concept_genus_name AS genus_name,
         ts.group AS group_name,
         -- terms.id AS term_id,
         -- terms.name_en AS term,
         -- CASE WHEN terms.code = 'ROO' AND ts.taxon_concept_genus_name IN ('Galanthus', 'Cyclamen', 'Sternbergia') THEN
         --     CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['LIV', ts.quantity::text, NULL, 'CM']
         --     ELSE Array['LIV', NULL, ts.quantity::text, units.code]
         --     END
         --      WHEN terms.code = 'PKY' THEN
         --     CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['KEY', (ts.quantity*52)::text, NULL, units.code]
         --     ELSE Array['KEY', NULL, (ts.quantity*52)::text, units.code]
         --     END
         -- END AS termcode_imp_exp_qty_unit,
         -- units.id AS unit_id,
         -- units.name_en AS unit,
         exporters.id AS exporter_id,
         exporters.iso_code2 AS exporter_iso,
         exporters.name_en AS exporter,
         importers.id AS importer_id,
         importers.iso_code2 AS importer_iso,
         importers.name_en AS importer,
         origins.iso_code2 AS origin,
         purposes.id AS purpose_id,
         purposes.name_en AS purpose,
         sources.id AS source_id,
         sources.name_en AS source,
         ranks.id AS rank_id,
         ranks.name AS rank_name
  FROM trade_plus_group_view ts
  INNER JOIN species_listings listings ON listings.abbreviation = ts.appendix
  INNER JOIN trade_codes sources ON ts.source_id = sources.id
  INNER JOIN trade_codes purposes ON ts.purpose_id = purposes.id
  INNER JOIN ranks ON ranks.id = ts.taxon_concept_rank_id
  LEFT OUTER JOIN trade_codes terms ON ts.term_id = terms.id
  LEFT OUTER JOIN trade_codes units ON ts.unit_id = units.id
  LEFT OUTER JOIN geo_entities exporters ON ts.exporter_id = exporters.id
  LEFT OUTER JOIN geo_entities importers ON ts.importer_id = importers.id
  LEFT OUTER JOIN geo_entities origins ON ts.country_of_origin_id = origins.id
  WHERE ts.appendix != 'N'
  AND listings.designation_id = 1
  AND terms.code != 'COS'
  )
AS s
