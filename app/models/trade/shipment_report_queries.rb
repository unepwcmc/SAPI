module Trade::ShipmentReportQueries

  def raw_query(options)
    "SELECT
      shipments.id,
      year,
      appendix,
      taxon_concept_id,
      full_name_with_spp(ranks.name, taxon_concept_full_name) AS taxon,
      reported_taxon_concept_id,
      full_name_with_spp(reported_taxon_ranks.name, reported_taxon_concept_full_name) AS reported_taxon,
      taxon_concept_class_name AS class_name,
      taxon_concept_order_name AS order_name,
      taxon_concept_family_name AS family_name,
      taxon_concept_genus_name AS genus_name,
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
      CASE WHEN quantity = 0 THEN NULL ELSE quantity END,
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
      sources.code AS source,
      import_permit_number,
      export_permit_number,
      origin_permit_number,
      import_permits_ids,
      export_permits_ids,
      origin_permits_ids,
      legacy_shipment_number,
      uc.name AS created_by,
      uu.name AS updated_by
    FROM (#{basic_query(options).to_sql}) shipments
    JOIN ranks
      ON ranks.id = taxon_concept_rank_id
    LEFT JOIN ranks AS reported_taxon_ranks
      ON reported_taxon_ranks.id = reported_taxon_concept_rank_id
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
    LEFT JOIN users as uc
      ON shipments.created_by_id = uc.id
    LEFT JOIN users as uu
      ON shipments.updated_by_id = uu.id"
  end

  def self.full_db_query_by_kingdom(year, kingdom)
    "SELECT
      shipments.id AS id,
      year AS year,
      appendix AS appendix,
      full_name_with_spp(ranks.name, taxon_concept_full_name) AS taxon,
      taxon_concept_id AS taxon_id,
      taxon_concept_class_name AS class,
      taxon_concept_order_name AS order,
      taxon_concept_family_name AS family,
      taxon_concept_genus_name AS genus,
      full_name_with_spp(reported_taxon_ranks.name, reported_taxon_concept_full_name) AS reported_taxon,
      reported_taxon_concept_id AS reported_taxon_id,
      terms.name_en AS term,
      CASE WHEN quantity = 0 THEN NULL ELSE quantity END,
      units.name_en AS unit,
      importers.iso_code2 AS importer,
      exporters.iso_code2 AS exporter,
      countries_of_origin.iso_code2 AS origin,
      purposes.code AS purpose,
      sources.code AS source,
      CASE
        WHEN reported_by_exporter THEN 'E'
        ELSE 'I'
      END AS reporter_type,
      import_permit_number AS import_permit,
      export_permit_number AS export_permit,
      origin_permit_number AS origin_permit,
      legacy_shipment_number AS legacy_shipment_no
    FROM trade_shipments_with_taxa_view AS shipments
    JOIN ranks
      ON ranks.id = taxon_concept_rank_id
    LEFT JOIN ranks AS reported_taxon_ranks
      ON reported_taxon_ranks.id = reported_taxon_concept_rank_id
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
    LEFT JOIN users as uc
      ON shipments.created_by_id = uc.id
    LEFT JOIN users as uu
      ON shipments.updated_by_id = uu.id
    LEFT JOIN taxon_concepts as tc_kingdom
      ON reported_taxon_concept_kingdom_id = tc_kingdom.id
    WHERE year = #{year} AND tc_kingdom.full_name = '#{kingdom}'
    ORDER BY shipments.id"
  end

  def self.full_db_query_by_year(year)
    "SELECT
      shipments.id AS id,
      year AS year,
      appendix AS appendix,
      full_name_with_spp(ranks.name, taxon_concept_full_name) AS taxon,
      taxon_concept_id AS taxon_id,
      taxon_concept_class_name AS class,
      taxon_concept_order_name AS order,
      taxon_concept_family_name AS family,
      taxon_concept_genus_name AS genus,
      full_name_with_spp(reported_taxon_ranks.name, reported_taxon_concept_full_name) AS reported_taxon,
      reported_taxon_concept_id AS reported_taxon_id,
      terms.name_en AS term,
      CASE WHEN quantity = 0 THEN NULL ELSE quantity END,
      units.name_en AS unit,
      importers.iso_code2 AS importer,
      exporters.iso_code2 AS exporter,
      countries_of_origin.iso_code2 AS origin,
      purposes.code AS purpose,
      sources.code AS source,
      CASE
        WHEN reported_by_exporter THEN 'E'
        ELSE 'I'
      END AS reporter_type,
      import_permit_number AS import_permit,
      export_permit_number AS export_permit,
      origin_permit_number AS origin_permit,
      legacy_shipment_number AS legacy_shipment_no
    FROM trade_shipments_with_taxa_view AS shipments
    JOIN ranks
      ON ranks.id = taxon_concept_rank_id
    LEFT JOIN ranks AS reported_taxon_ranks
      ON reported_taxon_ranks.id = reported_taxon_concept_rank_id
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
    LEFT JOIN users as uc
      ON shipments.created_by_id = uc.id
    LEFT JOIN users as uu
      ON shipments.updated_by_id = uu.id
    WHERE year = #{year}
    ORDER BY shipments.id"
  end

  def self.full_db_query_single_file(limit, offset)
    "SELECT
      shipments.id AS id,
      year AS year,
      appendix AS appendix,
      full_name_with_spp(ranks.name, taxon_concept_full_name) AS taxon,
      taxon_concept_id AS taxon_id,
      taxon_concept_class_name AS class,
      taxon_concept_order_name AS order,
      taxon_concept_family_name AS family,
      taxon_concept_genus_name AS genus,
      full_name_with_spp(reported_taxon_ranks.name, reported_taxon_concept_full_name) AS reported_taxon,
      reported_taxon_concept_id AS reported_taxon_id,
      terms.name_en AS term,
      CASE WHEN quantity = 0 THEN NULL ELSE quantity END,
      units.name_en AS unit,
      importers.iso_code2 AS importer,
      exporters.iso_code2 AS exporter,
      countries_of_origin.iso_code2 AS origin,
      purposes.code AS purpose,
      sources.code AS source,
      CASE
        WHEN reported_by_exporter THEN 'E'
        ELSE 'I'
      END AS reporter_type,
      import_permit_number AS import_permit,
      export_permit_number AS export_permit,
      origin_permit_number AS origin_permit,
      legacy_shipment_number AS legacy_shipment_no
    FROM trade_shipments_with_taxa_view AS shipments
    JOIN ranks
      ON ranks.id = taxon_concept_rank_id
    LEFT JOIN ranks AS reported_taxon_ranks
      ON reported_taxon_ranks.id = reported_taxon_concept_rank_id
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
    LEFT JOIN users as uc
      ON shipments.created_by_id = uc.id
    LEFT JOIN users as uu
      ON shipments.updated_by_id = uu.id
    ORDER BY shipments.id
    LIMIT #{limit} OFFSET #{offset}"
  end

  def self.full_db_query(limit, offset)
    "SELECT
      shipments.id AS id,
      year AS year,
      appendix AS appendix,
      full_name_with_spp(ranks.name, taxon_concept_full_name) AS taxon,
      taxon_concept_id AS taxon_id,
      taxon_concept_class_name AS class,
      taxon_concept_order_name AS order,
      taxon_concept_family_name AS family,
      taxon_concept_genus_name AS genus,
      full_name_with_spp(reported_taxon_ranks.name, reported_taxon_concept_full_name) AS reported_taxon,
      reported_taxon_concept_id AS reported_taxon_id,
      terms.name_en AS term,
      CASE WHEN quantity = 0 THEN NULL ELSE quantity END,
      units.name_en AS unit,
      importers.iso_code2 AS importer,
      exporters.iso_code2 AS exporter,
      countries_of_origin.iso_code2 AS origin,
      purposes.code AS purpose,
      sources.code AS source,
      CASE
        WHEN reported_by_exporter THEN 'E'
        ELSE 'I'
      END AS reporter_type,
      import_permit_number AS import_permit,
      export_permit_number AS export_permit,
      origin_permit_number AS origin_permit,
      legacy_shipment_number AS legacy_shipment_no,
      uc.name AS created_by,
      uu.name AS updated_by
    FROM trade_shipments_with_taxa_view AS shipments
    JOIN ranks
      ON ranks.id = taxon_concept_rank_id
    LEFT JOIN ranks AS reported_taxon_ranks
      ON reported_taxon_ranks.id = reported_taxon_concept_rank_id
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
    LEFT JOIN users as uc
      ON shipments.created_by_id = uc.id
    LEFT JOIN users as uu
      ON shipments.updated_by_id = uu.id
    ORDER BY shipments.id
    LIMIT #{limit} OFFSET #{offset}"
  end

  def self.partial_db_query(limit, offset, updated_at: nil, created_at: nil)
    full_db_query(limit, offset) unless updated_at || created_at
    where = if updated_at && !created_at
              "shipments.updated_at > '#{updated_at}'"
            elsif created_at && !updated_at
              "shipments.created_at > '#{created_at}'"
            else
              "shipments.updated_at > '#{updated_at}' AND shipments.created_at < '#{created_at}'"
            end
    "SELECT
      shipments.id AS id,
      year AS year,
      appendix AS appendix,
      full_name_with_spp(ranks.name, taxon_concept_full_name) AS taxon,
      taxon_concept_id AS taxon_id,
      taxon_concept_class_name AS class,
      taxon_concept_order_name AS order,
      taxon_concept_family_name AS family,
      taxon_concept_genus_name AS genus,
      full_name_with_spp(reported_taxon_ranks.name, reported_taxon_concept_full_name) AS reported_taxon,
      reported_taxon_concept_id AS reported_taxon_id,
      terms.name_en AS term,
      CASE WHEN quantity = 0 THEN NULL ELSE quantity END,
      units.name_en AS unit,
      importers.iso_code2 AS importer,
      exporters.iso_code2 AS exporter,
      countries_of_origin.iso_code2 AS origin,
      purposes.code AS purpose,
      sources.code AS source,
      CASE
        WHEN reported_by_exporter THEN 'E'
        ELSE 'I'
      END AS reporter_type,
      import_permit_number AS import_permit,
      export_permit_number AS export_permit,
      origin_permit_number AS origin_permit,
      legacy_shipment_number AS legacy_shipment_no,
      uc.name AS created_by,
      uu.name AS updated_by,
      shipments.updated_at AS updated_at,
      shipments.created_at AS created_at
    FROM trade_shipments_with_taxa_view AS shipments
    JOIN ranks
      ON ranks.id = taxon_concept_rank_id
    LEFT JOIN ranks AS reported_taxon_ranks
      ON reported_taxon_ranks.id = reported_taxon_concept_rank_id
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
    LEFT JOIN users as uc
      ON shipments.created_by_id = uc.id
    LEFT JOIN users as uu
      ON shipments.updated_by_id = uu.id
    WHERE #{where}
    ORDER BY shipments.id
    LIMIT #{limit} OFFSET #{offset}"
  end

  def comptab_query(options)
    "SELECT
      year,
      appendix,
      taxon_concept_id,
      full_name_with_spp(ranks.name, taxon_concept_full_name) AS taxon,
      taxon_concept_class_name AS class_name,
      taxon_concept_order_name AS order_name,
      taxon_concept_family_name AS family_name,
      taxon_concept_genus_name AS genus_name,
      importer_id,
      importers.iso_code2 AS importer,
      exporter_id,
      exporters.iso_code2 AS exporter,
      country_of_origin_id,
      countries_of_origin.iso_code2 AS country_of_origin,
      TRIM_DECIMAL_ZERO(
        SUM(CASE WHEN reported_by_exporter THEN NULL ELSE quantity END)
      ) AS importer_quantity,
      TRIM_DECIMAL_ZERO(
        SUM(CASE WHEN reported_by_exporter THEN quantity ELSE NULL END)
      ) AS exporter_quantity,
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
    FROM (#{basic_query(options).to_sql}) shipments
    JOIN ranks
      ON ranks.id = taxon_concept_rank_id
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
      taxon_concept_family_name,
      taxon_concept_id,
      taxon_concept_full_name,
      class_name,
      order_name,
      family_name,
      genus_name,
      ranks.name,
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
      sources.code
    ORDER BY
      year ASC,
      appendix,
      taxon_concept_family_name,
      taxon_concept_full_name,
      importers.iso_code2,
      exporters.iso_code2,
      countries_of_origin.iso_code2,
      terms.code,
      units.code,
      purposes.code,
      sources.code"
  end

  # this query is the basis of all gross / net reports,
  # which perform further groupings
  # it is an envelope for the shipments query
  def gross_net_query(options)
    "SELECT
      year,
      appendix,
      taxon_concept_id,
      full_name_with_spp(ranks.name, taxon_concept_full_name) AS taxon,
      importer_id,
      importers.iso_code2 AS importer,
      exporter_id,
      exporters.iso_code2 AS exporter,
      TRIM_DECIMAL_ZERO(
        GREATEST(
          SUM(CASE WHEN reported_by_exporter THEN NULL ELSE quantity END),
          SUM(CASE WHEN reported_by_exporter THEN quantity ELSE NULL END)
        )
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
    FROM (#{basic_query(options).to_sql}) shipments
    JOIN ranks
      ON ranks.id = taxon_concept_rank_id
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
      taxon_concept_full_name,
      ranks.name,
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

  def gross_exports_query(options)
    "WITH gross_net_subquery AS (
      #{gross_net_query(options)}
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
      TRIM_DECIMAL_ZERO(
        SUM(gross_quantity)
      ) AS gross_quantity
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
      exporter
    ORDER BY
      appendix,
      taxon,
      term,
      unit,
      country"
  end

  def gross_imports_query(options)
    "WITH gross_net_subquery AS (
      #{gross_net_query(options)}
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
      TRIM_DECIMAL_ZERO(
        SUM(gross_quantity)
      ) AS gross_quantity
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
      importer
    ORDER BY
      appendix,
      taxon,
      term,
      unit,
      country"
  end

  def net_exports_query(options)
    "WITH exports AS (
      #{gross_exports_query(options)}
    ), imports AS (
      #{gross_imports_query(options)}
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
      TRIM_DECIMAL_ZERO(
        CASE
          WHEN (exports.gross_quantity - COALESCE(imports.gross_quantity, 0)) > 0
          THEN exports.gross_quantity - COALESCE(imports.gross_quantity, 0)
          ELSE NULL
        END
      ) AS gross_quantity
    FROM exports
    LEFT JOIN imports
    ON exports.taxon_concept_id = imports.taxon_concept_id
    AND exports.appendix = imports.appendix
    AND exports.year = imports.year
    AND exports.term_id = imports.term_id
    AND (exports.unit_id = imports.unit_id OR exports.unit_id IS NULL AND imports.unit_id IS NULL)
    AND exports.year = imports.year
    AND exports.country_id = imports.country_id
    WHERE (exports.gross_quantity - COALESCE(imports.gross_quantity, 0)) > 0
    ORDER BY
      appendix,
      taxon,
      term,
      unit,
      country"
  end

  def net_imports_query(options)
    "WITH exports AS (
      #{gross_exports_query(options)}
    ), imports AS (
      #{gross_imports_query(options)}
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
      TRIM_DECIMAL_ZERO(
        CASE
          WHEN (imports.gross_quantity - COALESCE(exports.gross_quantity, 0)) > 0
          THEN imports.gross_quantity - COALESCE(exports.gross_quantity, 0)
          ELSE NULL
        END
      ) AS gross_quantity
    FROM imports
    LEFT JOIN exports
    ON exports.taxon_concept_id = imports.taxon_concept_id
    AND exports.appendix = imports.appendix
    AND exports.year = imports.year
    AND exports.term_id = imports.term_id
    AND (exports.unit_id = imports.unit_id OR exports.unit_id IS NULL AND imports.unit_id IS NULL)
    AND exports.country_id = imports.country_id
    WHERE (imports.gross_quantity - COALESCE(exports.gross_quantity, 0)) > 0
    ORDER BY
      appendix,
      taxon,
      term,
      unit,
      country"
  end

end
