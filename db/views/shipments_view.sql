DROP VIEW IF EXISTS trade_shipments_view;
CREATE VIEW trade_shipments_view AS
SELECT
  shipments.id,
  year,
  appendix,
  taxon_concept_id,
  taxon_concepts.full_name AS taxon,
  reported_taxon_concept_id,
  reported_taxon_concepts.full_name AS reported_taxon,
  importer_id,
  importers.iso_code2 AS importer,
  exporter_id,
  exporters.iso_code2 AS exporter,
  reported_by_exporter,
  CASE
    WHEN reported_by_exporter THEN 'E'
    ELSE 'I'
  END AS reporter_type,
  country_of_origin_id,
  countries_of_origin.iso_code2 AS country_of_origin,
  quantity,
  unit_id,
  units.code AS unit,
  term_id,
  terms.code AS term,
  purpose_id,
  purposes.code AS purpose,
  source_id,
  sources.code AS source,
  import_permit_id,
  import_permits.number AS import_permit_number,
  ARRAY_AGG(export_permits.id) AS export_permits_ids,
  ARRAY_TO_STRING(ARRAY_AGG(export_permits.number), ';') AS export_permit_number,
  country_of_origin_permit_id,
  countries_of_origin_permits.number AS country_of_origin_permit_number
FROM trade_shipments shipments
JOIN taxon_concepts
  ON taxon_concept_id = taxon_concepts.id
LEFT JOIN taxon_concepts reported_taxon_concepts
  ON reported_taxon_concept_id = reported_taxon_concepts.id
JOIN geo_entities importers
  ON importers.id = importer_id
JOIN geo_entities exporters
  ON exporters.id = exporter_id
LEFT JOIN geo_entities countries_of_origin
  ON countries_of_origin.id = country_of_origin_id
LEFT JOIN trade_codes units
  ON units.id = unit_id
JOIN trade_codes terms
  ON terms.id = term_id
LEFT JOIN trade_codes purposes
  ON purposes.id = purpose_id
LEFT JOIN trade_codes sources
  ON sources.id = source_id
LEFT JOIN trade_permits import_permits
  ON import_permits.id = import_permit_id
LEFT JOIN trade_shipment_export_permits
  ON trade_shipment_export_permits.trade_shipment_id = shipments.id
LEFT JOIN trade_permits export_permits
  ON export_permits.id = trade_shipment_export_permits.trade_permit_id
LEFT JOIN trade_permits countries_of_origin_permits
  ON countries_of_origin_permits.id = country_of_origin_permit_id
GROUP BY
  shipments.id,
  year,
  appendix,
  taxon_concept_id,
  taxon_concepts.full_name,
  reported_taxon_concept_id,
  reported_taxon_concepts.full_name,
  importer_id,
  importers.iso_code2,
  exporter_id,
  exporters.iso_code2,
  countries_of_origin.iso_code2,
  quantity,
  unit_id,
  units.code,
  term_id,
  terms.code,
  purpose_id,
  purposes.code,
  source_id,
  sources.code,
  import_permit_id,
  import_permits.number,
  country_of_origin_permit_id,
  countries_of_origin_permits.number,
  trade_shipment_export_permits.trade_shipment_id;