DROP VIEW IF EXISTS trade_shipments_comptab_view;
CREATE VIEW trade_shipments_comptab_view AS
SELECT
  year,
  appendix,
  taxon_concepts.data->'family_name' AS family,
  taxon_concept_id,
  taxon_concepts.full_name AS taxon,
  importer_id,
  importers.iso_code2 AS importer,
  exporter_id,
  exporters.iso_code2 AS exporter,
  country_of_origin_id,
  countries_of_origin.iso_code2 AS country_of_origin,
  SUM(CASE WHEN reported_by_exporter THEN 0 ELSE quantity END) AS importer_quantity,
  SUM(CASE WHEN reported_by_exporter THEN quantity ELSE 0 END) AS exporter_quantity,
  term_id,
  terms.code AS term,
  terms.name_en AS term_name_en,
  terms.name_es AS term_name_es,
  terms.name_fr AS term_name_fr,
  unit_id,
  units.code AS unit,
  units.name_en AS unit_name_en,
  units.name_es AS unit_name_es,
  units.name_fr AS unit_name_fr,
  purpose_id,
  purposes.code AS purpose,
  source_id,
  sources.code AS source
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
GROUP BY
  year,
  appendix,
  taxon_concepts.data,
  taxon_concept_id,
  taxon_concepts.full_name,
  importer_id,
  importers.iso_code2,
  exporter_id,
  exporters.iso_code2,
  country_of_origin_id,
  countries_of_origin.iso_code2,
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
  sources.code;
