DROP VIEW IF EXISTS trade_shipments_view;
CREATE VIEW trade_shipments_view AS
WITH shipments AS (
  SELECT
    shipments.id,
    year,
    appendix,
    taxon_concept_id,
    full_name_with_spp(ranks.name, taxon_concepts.full_name) AS taxon,
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
    units.name_en AS unit_name_en,
    units.name_es AS unit_name_es,
    units.name_fr AS unit_name_fr,
    term_id,
    terms.code AS term,
    terms.name_en AS term_name_en,
    terms.name_es AS term_name_es,
    terms.name_fr AS term_name_fr,
    purpose_id,
    purposes.code AS purpose,
    source_id,
    sources.code AS source
  FROM trade_shipments shipments
  JOIN taxon_concepts
    ON taxon_concept_id = taxon_concepts.id
  JOIN ranks
    ON ranks.id = taxon_concepts.rank_id
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
  GROUP BY
    shipments.id,
    year,
    appendix,
    taxon_concept_id,
    taxon_concepts.full_name,
    ranks.name,
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
    units.name_en,
    units.name_es,
    units.name_fr,
    term_id,
    terms.code,
    terms.name_en,
    terms.name_es,
    terms.name_fr,
    purpose_id,
    purposes.code,
    source_id,
    sources.code
), shipments_with_import_permits AS (
SELECT trade_shipment_import_permits.trade_shipment_id,
  ARRAY_AGG(trade_shipment_import_permits.trade_permit_id) AS import_permits_ids,
  ARRAY_TO_STRING(ARRAY_AGG(import_permits.number), ';') AS import_permit_number
FROM trade_shipment_import_permits
JOIN trade_permits import_permits
  ON import_permits.id = trade_shipment_import_permits.trade_permit_id
GROUP BY trade_shipment_import_permits.trade_shipment_id
), shipments_with_export_permits AS (
SELECT trade_shipment_export_permits.trade_shipment_id,
  ARRAY_AGG(trade_shipment_export_permits.trade_permit_id) AS export_permits_ids,
  ARRAY_TO_STRING(ARRAY_AGG(export_permits.number), ';') AS export_permit_number
FROM trade_shipment_export_permits
JOIN trade_permits export_permits
  ON export_permits.id = trade_shipment_export_permits.trade_permit_id
GROUP BY trade_shipment_export_permits.trade_shipment_id
), shipments_with_origin_permits AS (
SELECT trade_shipment_origin_permits.trade_shipment_id,
  ARRAY_AGG(trade_shipment_origin_permits.trade_permit_id) AS origin_permits_ids,
  ARRAY_TO_STRING(ARRAY_AGG(origin_permits.number), ';') AS origin_permit_number
FROM trade_shipment_origin_permits
JOIN trade_permits origin_permits
  ON origin_permits.id = trade_shipment_origin_permits.trade_permit_id
GROUP BY trade_shipment_origin_permits.trade_shipment_id
)
SELECT shipments.*, import_permits_ids, import_permit_number, export_permits_ids, export_permit_number, origin_permits_ids, origin_permit_number
FROM shipments
LEFT JOIN shipments_with_import_permits si ON shipments.id = si.trade_shipment_id
LEFT JOIN shipments_with_export_permits se ON shipments.id = se.trade_shipment_id
LEFT JOIN shipments_with_origin_permits so ON shipments.id = so.trade_shipment_id;