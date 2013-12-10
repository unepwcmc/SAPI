-- CREATE TYPE netgross_report_row AS (
--   year integer,
--   taxon text,
--   gross_quantity numeric
-- );

-- CREATE OR REPLACE FUNCTION trade_shipments_netgross_report(
--   ignore_purpose BOOLEAN, ignore_source BOOLEAN, ignore_origin BOOLEAN
-- )
-- RETURNS SETOF netgross_report_row
-- LANGUAGE plpgsql
-- AS $$
--   DECLARE
--   r netgross_report_row%ROWTYPE;
--   BEGIN
--     FOR r IN SELECT year, taxon, gross_quantity
--     FROM trade_shipments_netgross_view
--     LOOP
--       RETURN NEXT r;
--     END LOOP;
--   RETURN;
--   END;
-- $$;

DROP VIEW IF EXISTS trade_shipments_netgross_view CASCADE;
CREATE VIEW trade_shipments_netgross_view AS
SELECT
  year,
  appendix,
  taxon_concept_id,
  taxon_concepts.full_name AS taxon,
  importer_id,
  importers.iso_code2 AS importer,
  exporter_id,
  exporters.iso_code2 AS exporter,
  -- country_of_origin_id,
  -- countries_of_origin.iso_code2 AS country_of_origin,
  GREATEST(
    SUM(CASE WHEN reported_by_exporter THEN 0 ELSE quantity END),
    SUM(CASE WHEN reported_by_exporter THEN quantity ELSE 0 END)
  ) AS gross_quantity,
  term_id,
  terms.code AS term,
  terms.name_en AS term_name_en,
  terms.name_es AS term_name_es,
  terms.name_fr AS term_name_fr,
  unit_id,
  units.code AS unit,
  units.name_en AS unit_name_en,
  units.name_es AS unit_name_es,
  units.name_fr AS unit_name_fr
  -- purpose_id,
  -- purposes.code AS purpose,
  -- source_id,
  -- sources.code AS source
FROM trade_shipments shipments
JOIN taxon_concepts
  ON taxon_concept_id = taxon_concepts.id
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
  taxon_concept_id,
  taxon_concepts.full_name,
  importer_id,
  importers.iso_code2,
  exporter_id,
  exporters.iso_code2,
  -- country_of_origin_id,
  -- countries_of_origin.iso_code2,
  unit_id,
  units.code,
  units.name_en,
  units.name_es,
  units.name_fr,
  term_id,
  terms.code,
  terms.name_en,
  terms.name_es,
  terms.name_fr;
  -- purpose_id,
  -- purposes.code,
  -- source_id,
  -- sources.code;

DROP VIEW IF EXISTS trade_shipments_gross_exports_view;
CREATE VIEW trade_shipments_gross_exports_view AS
SELECT
  year,
  appendix,
  taxon_concept_id,
  taxon,
  term_id,
  term,
  term_name_en,
  term_name_es,
  term_name_fr,
  unit_id,
  unit,
  unit_name_en,
  unit_name_es,
  unit_name_fr,
  exporter_id AS country_id,
  exporter AS country,
  SUM(gross_quantity) AS gross_quantity
FROM trade_shipments_netgross_view
GROUP BY
  year,
  appendix,
  taxon_concept_id,
  taxon,
  term_id,
  term,
  term_name_en,
  term_name_es,
  term_name_fr,
  unit_id,
  unit,
  unit_name_en,
  unit_name_es,
  unit_name_fr,
  exporter_id,
  exporter;

DROP VIEW IF EXISTS trade_shipments_gross_imports_view;
CREATE VIEW trade_shipments_gross_imports_view AS
SELECT
  year,
  appendix,
  taxon_concept_id,
  taxon,
  term_id,
  term,
  term_name_en,
  term_name_es,
  term_name_fr,
  unit_id,
  unit,
  unit_name_en,
  unit_name_es,
  unit_name_fr,
  importer_id AS country_id,
  importer AS country,
  SUM(gross_quantity) AS gross_quantity
FROM trade_shipments_netgross_view
GROUP BY
  year,
  appendix,
  taxon_concept_id,
  taxon,
  term_id,
  term,
  term_name_en,
  term_name_es,
  term_name_fr,
  unit_id,
  unit,
  unit_name_en,
  unit_name_es,
  unit_name_fr,
  importer_id,
  importer;

DROP VIEW IF EXISTS trade_shipments_net_exports_view;
CREATE VIEW trade_shipments_net_exports_view AS
SELECT
  exports.year,
  exports.appendix,
  exports.taxon_concept_id,
  exports.taxon,
  exports.term_id,
  exports.term,
  exports.term_name_en,
  exports.term_name_es,
  exports.term_name_fr,
  exports.unit_id,
  exports.unit,
  exports.unit_name_en,
  exports.unit_name_es,
  exports.unit_name_fr,
  exports.country_id,
  exports.country,
  CASE
    WHEN (exports.gross_quantity - imports.gross_quantity) > 0
    THEN exports.gross_quantity - imports.gross_quantity
    ELSE 0
  END AS gross_quantity
FROM trade_shipments_gross_exports_view exports
JOIN trade_shipments_gross_imports_view imports
ON exports.taxon_concept_id = imports.taxon_concept_id
AND exports.term_id = imports.term_id
AND exports.unit_id = imports.unit_id
AND exports.year = imports.year
AND exports.country_id = imports.country_id;

DROP VIEW IF EXISTS trade_shipments_net_imports_view;
CREATE VIEW trade_shipments_net_imports_view AS
SELECT
  imports.year,
  imports.appendix,
  imports.taxon_concept_id,
  imports.taxon,
  imports.term_id,
  imports.term,
  imports.term_name_en,
  imports.term_name_es,
  imports.term_name_fr,
  imports.unit_id,
  imports.unit,
  imports.unit_name_en,
  imports.unit_name_es,
  imports.unit_name_fr,
  imports.country_id,
  imports.country,
  CASE
    WHEN (imports.gross_quantity - exports.gross_quantity) > 0
    THEN imports.gross_quantity - exports.gross_quantity
    ELSE 0
  END AS gross_quantity
FROM trade_shipments_gross_exports_view exports
JOIN trade_shipments_gross_imports_view imports
ON exports.taxon_concept_id = imports.taxon_concept_id
AND exports.term_id = imports.term_id
AND exports.unit_id = imports.unit_id
AND exports.country_id = imports.country_id;
