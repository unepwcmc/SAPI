SELECT DISTINCT *
FROM (
  SELECT ts.id, ts.year, ts.appendix, listings.id AS appendix_id,
         ts.taxon_id, ts.taxon_concept_author_year AS author_year,
         ts.taxon_concept_name_status AS name_status,
         ts.taxon_name AS taxon,
         ts.taxon_concept_phylum_id AS phylum_id,
         ts.group_name AS group_name,
         ts.taxon_concept_class_id AS class_id,
         ts.class_name AS class_name,
         ts.taxon_concept_order_id AS order_id,
         ts.order_name AS order_name,
         ts.taxon_concept_family_id AS family_id,
         ts.family_name AS family_name,
         ts.taxon_concept_genus_id AS genus_id,
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
         sources.name_en AS source,
         ranks.id AS rank_id,
         ranks.name AS rank_name
  FROM trade_plus_static_with_taxa_view ts
  INNER JOIN ranks ON ranks.id = ts.taxon_concept_rank_id
  INNER JOIN species_listings listings ON listings.abbreviation = ts.appendix
  LEFT OUTER JOIN trade_codes sources ON ts.source = sources.code
  LEFT OUTER JOIN trade_codes purposes ON ts.purpose = purposes.code
  LEFT OUTER JOIN trade_codes terms ON ts.term = terms.name_en
  LEFT OUTER JOIN trade_codes units ON ts.unit = units.name_en
  LEFT OUTER JOIN geo_entities exporters ON ts.exporter = exporters.name_en
  LEFT OUTER JOIN geo_entities importers ON ts.importer = importers.name_en
  LEFT OUTER JOIN geo_entities origins ON ts.origin = origins.name_en
  WHERE ts.appendix != 'N'
  )
  AS s
