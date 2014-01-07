module Trade::ShipmentReportQueries

  def comptab_query
  "SELECT
    year,
    appendix,
    taxon_concepts.data->'family_name' AS family,
    taxon_concept_id,
    taxon_concepts.full_name AS taxon,
    importer_id,
    importers.iso_code2 AS importer,
    exporter_id,
    exporters.iso_code2 AS exporter,
    CASE 
      WHEN country_of_origin_id IS NULL THEN 9991
      ELSE country_of_origin_id
      END AS country_of_origin_id,
    countries_of_origin.iso_code2 AS country_of_origin,
    SUM(CASE WHEN reported_by_exporter THEN 0 ELSE quantity END) AS importer_quantity,
    SUM(CASE WHEN reported_by_exporter THEN quantity ELSE 0 END) AS exporter_quantity,
    term_id,
    terms.code AS term,
    terms.name_en AS term_name_en,
    terms.name_es AS term_name_es,
    terms.name_fr AS term_name_fr,
    CASE 
      WHEN unit_id IS NULL THEN 9991
      ELSE unit_id 
      END AS unit_id,
    unit,
    units.name_en AS unit_name_en,
    units.name_es AS unit_name_es,
    units.name_fr AS unit_name_fr,
    CASE 
      WHEN purpose_id IS NULL THEN 9993
      ELSE purpose_id 
      END AS purpose_id,
    purpose,
    CASE 
      WHEN source_id IS NULL THEN 9992
      ELSE source_id 
      END AS source_id,
    source
  FROM (#{@search.query.to_sql}) shipments
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
    sources.code"
  end

  # this query is the basis of all gross / net reports,
  # which perform further groupings
  # it is an envelope for the shipments query
  def gross_net_query
  "SELECT
    year,
    appendix,
    taxon_concept_id,
    taxon_concepts.full_name AS taxon,
    importer_id,
    importers.iso_code2 AS importer,
    exporter_id,
    exporters.iso_code2 AS exporter,
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
  FROM (#{@search.query.to_sql}) shipments
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
    unit_id,
    units.code,
    units.name_en,
    units.name_es,
    units.name_fr,
    term_id,
    terms.code,
    terms.name_en,
    terms.name_es,
    terms.name_fr"
  end

  def gross_exports_query
  "WITH gross_net_subquery AS (
    #{gross_net_query}
  )
  #{gross_exports_subquery}"
  end

  def gross_exports_subquery
  "SELECT
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
  FROM gross_net_subquery
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
    exporter"
  end

  def gross_imports_query
  "WITH gross_net_subquery AS (
    #{gross_net_query}
  )
  #{gross_imports_subquery}"
  end

  def gross_imports_subquery
  "SELECT
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
  FROM gross_net_subquery
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
    importer"
  end

  def net_exports_query
  "WITH exports AS (
    #{gross_exports_query}
  ), imports AS (
    #{gross_imports_query}
  )
  #{net_exports_subquery}"
  end

  def net_exports_subquery
  "SELECT
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
      WHEN (exports.gross_quantity - COALESCE(imports.gross_quantity, 0)) > 0
      THEN exports.gross_quantity - COALESCE(imports.gross_quantity, 0)
      ELSE 0
    END AS gross_quantity
  FROM exports
  LEFT JOIN imports
  ON exports.taxon_concept_id = imports.taxon_concept_id
  AND exports.appendix = imports.appendix
  AND exports.year = imports.year
  AND exports.term_id = imports.term_id
  AND (exports.unit_id = imports.unit_id OR exports.unit_id IS NULL AND imports.unit_id IS NULL)
  AND exports.year = imports.year
  AND exports.country_id = imports.country_id"
  end

  def net_imports_query
  "WITH exports AS (
    #{gross_exports_query}
  ), imports AS (
    #{gross_imports_query}
  )
  #{net_imports_subquery}"
  end

  def net_imports_subquery
  "SELECT
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
      WHEN (imports.gross_quantity - COALESCE(exports.gross_quantity, 0)) > 0
      THEN imports.gross_quantity - COALESCE(exports.gross_quantity, 0)
      ELSE 0
    END AS gross_quantity
  FROM imports
  LEFT JOIN exports
  ON exports.taxon_concept_id = imports.taxon_concept_id
  AND exports.appendix = imports.appendix
  AND exports.year = imports.year
  AND exports.term_id = imports.term_id
  AND (exports.unit_id = imports.unit_id OR exports.unit_id IS NULL AND imports.unit_id IS NULL)
  AND exports.country_id = imports.country_id"
  end

end
