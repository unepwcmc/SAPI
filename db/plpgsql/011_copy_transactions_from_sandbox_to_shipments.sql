CREATE OR REPLACE FUNCTION copy_transactions_from_sandbox_to_shipments(
  annual_report_upload_id INTEGER
  ) RETURNS INTEGER
  LANGUAGE plpgsql
  AS $$
DECLARE
  aru trade_annual_report_uploads%ROWTYPE;
  table_name TEXT;
  cites_taxonomy_id INTEGER;
  reported_by_exporter BOOLEAN;
  inserted_rows INTEGER;
  inserted_shipments INTEGER;
  total_shipments INTEGER;
  sql TEXT;
  permit_type TEXT;
BEGIN
  SELECT * INTO aru FROM trade_annual_report_uploads WHERE id = annual_report_upload_id;
  IF NOT FOUND THEN
    RAISE NOTICE '[%] Annual report upload not found.', table_name;
    RETURN -1;
  END IF;
  IF aru.point_of_view = 'E' THEN
    reported_by_exporter := TRUE;
  ELSE
    reported_by_exporter := FALSE;
  END IF;
  SELECT id INTO cites_taxonomy_id FROM taxonomies WHERE name = 'CITES_EU';
  IF NOT FOUND THEN
    RAISE NOTICE '[%] Taxonomy not found.', table_name;
    RETURN -1;
  END IF;
  table_name = 'trade_sandbox_' || annual_report_upload_id;
  EXECUTE 'SELECT COUNT(*) FROM ' || table_name INTO total_shipments;
  RAISE INFO '[%] Copying % rows from %', table_name, total_shipments, table_name;


  sql := 'WITH split_export_permits AS (
      SELECT id,
      SQUISH(regexp_split_to_table(export_permit, ''[:;,]'')) AS export_permit,
      trading_partner
      FROM '|| table_name || '
    ), split_import_permits AS (
      SELECT id,
      SQUISH(regexp_split_to_table(import_permit, ''[:;,]'')) AS import_permit,
      country_of_origin, trading_partner
      FROM '|| table_name || '
    ), split_origin_permits AS (
      SELECT id,
      SQUISH(regexp_split_to_table(origin_permit, ''[:;,]'')) AS origin_permit,
      country_of_origin
      FROM '|| table_name || '
    )
    SELECT origin_permit, geo_entities.id
    FROM split_origin_permits
    INNER JOIN geo_entities ON geo_entities.iso_code2 = country_of_origin
    WHERE origin_permit IS NOT NULL AND country_of_origin IS NOT NULL
      AND NOT EXISTS (
        SELECT id FROM trade_permits
        WHERE geo_entity_id = geo_entities.id
          AND number = origin_permit
      )';
  IF aru.point_of_view = 'E' THEN
    sql := sql || 'UNION
      SELECT export_permit, ' || aru.trading_country_id ||
      '
      FROM split_export_permits
      INNER JOIN geo_entities ON geo_entities.iso_code2 = trading_partner
      WHERE export_permit IS NOT NULL
        AND NOT EXISTS (
          SELECT id from trade_permits
          WHERE geo_entity_id = ' || aru.trading_country_id ||
          ' AND number = export_permit
        )
      UNION
      SELECT import_permit, geo_entities.id
      FROM split_import_permits
      INNER JOIN geo_entities ON geo_entities.iso_code2 = trading_partner
      WHERE import_permit IS NOT NULL
        AND NOT EXISTS (
          SELECT id from trade_permits
          WHERE geo_entity_id = geo_entities.id
            AND number = import_permit
        )';
  ELSE
    sql := sql || 'UNION
      SELECT DISTINCT export_permit, geo_entities.id
      FROM split_export_permits
      INNER JOIN geo_entities ON geo_entities.iso_code2 = trading_partner
      WHERE export_permit IS NOT NULL
        AND NOT EXISTS (
          SELECT id from trade_permits
          WHERE geo_entity_id = geo_entities.id
            AND number = export_permit
        )
      UNION
      SELECT DISTINCT import_permit, ' || aru.trading_country_id ||
      '
      FROM split_import_permits
      INNER JOIN geo_entities ON geo_entities.iso_code2 = trading_partner
      WHERE import_permit IS NOT NULL
        AND NOT EXISTS (
          SELECT id from trade_permits
          WHERE geo_entity_id = ' || aru.trading_country_id ||
          ' AND number = import_permit
        )';
  END IF;

  sql := 'WITH permits_to_be_inserted (number, geo_entity_id) AS (' ||
    sql ||
    '
    EXCEPT
    SELECT number, geo_entity_id FROM trade_permits
  )
  INSERT INTO trade_permits(number, geo_entity_id, created_at, updated_at)
  SELECT DISTINCT number, geo_entity_id, current_date, current_date
  FROM permits_to_be_inserted';

  EXECUTE sql;

  GET DIAGNOSTICS inserted_rows = ROW_COUNT;
  RAISE INFO '[%] Inserted % permits', table_name, inserted_rows;

  sql := '
    CREATE TEMP TABLE ' || table_name || '_for_submit AS
    WITH resolved_reported_taxa AS (
      SELECT DISTINCT ON (1)
        sandbox_table.id AS sandbox_shipment_id,
        taxon_concepts.id AS taxon_concept_id
      FROM ' || table_name || ' sandbox_table
      JOIN taxon_concepts
        ON UPPER(taxon_concepts.full_name) = UPPER(squish(sandbox_table.species_name))
        AND taxonomy_id = ' || cites_taxonomy_id ||
      '
      ORDER BY 1, CASE
        WHEN taxon_concepts.name_status = ''A'' THEN 1
        ELSE 2
      END
    ), resolved_taxa AS (
      SELECT DISTINCT ON (1)
        sandbox_shipment_id,
        resolved_reported_taxa.taxon_concept_id,
        accepted_taxon_concepts.id AS accepted_taxon_concept_id
      FROM resolved_reported_taxa
      LEFT JOIN taxon_relationships
        ON taxon_relationships.other_taxon_concept_id = resolved_reported_taxa.taxon_concept_id
      LEFT JOIN taxon_relationship_types
        ON taxon_relationships.taxon_relationship_type_id = taxon_relationship_types.id
        AND taxon_relationship_types.name = ''HAS_SYNONYM''
      LEFT JOIN taxon_concepts accepted_taxon_concepts
        ON accepted_taxon_concepts.id = taxon_relationships.taxon_concept_id
        AND taxonomy_id = ' || cites_taxonomy_id ||
      '
      ORDER BY 1, CASE
        WHEN accepted_taxon_concepts.name_status = ''A'' THEN 1
        ELSE 2
      END
    ), inserted_shipments AS (
      INSERT INTO trade_shipments (
        source_id,
        unit_id,
        purpose_id,
        term_id,
        quantity,
        appendix,
        trade_annual_report_upload_id,
        exporter_id,
        importer_id,
        country_of_origin_id,
        reported_by_exporter,
        taxon_concept_id,
        reported_taxon_concept_id,
        year,
        sandbox_id,
        created_at,
        updated_at
      )
      SELECT
        sources.id AS source_id,
        units.id AS unit_id,
        purposes.id AS purpose_id,
        terms.id AS term_id,
        sandbox_table.quantity::NUMERIC AS quantity,
        sandbox_table.appendix,' ||
        aru.id || 'AS trade_annual_report_upload_id,
        exporters.id AS exporter_id,
        importers.id AS importer_id,
        origins.id AS country_of_origin_id,' ||
        reported_by_exporter || ' AS reported_by_exporter,
        CASE WHEN resolved_taxa.accepted_taxon_concept_id IS NOT NULL
        THEN resolved_taxa.accepted_taxon_concept_id
        ELSE resolved_taxa.taxon_concept_id
        END AS taxon_concept_id,
        resolved_taxa.taxon_concept_id AS reported_taxon_concept_id,
        sandbox_table.year::INTEGER AS year,
        sandbox_table.id AS sandbox_id,
        current_timestamp,
        current_timestamp
      FROM '|| table_name || ' sandbox_table
      JOIN resolved_taxa ON sandbox_table.id = resolved_taxa.sandbox_shipment_id';

    IF reported_by_exporter THEN
      sql := sql ||
      '
      JOIN geo_entities AS exporters ON
        exporters.id = ' || aru.trading_country_id ||
      '
      JOIN geo_entities AS importers ON
        importers.iso_code2 = sandbox_table.trading_partner';
    ELSE
      sql := sql ||
      '
      JOIN geo_entities AS exporters ON
        exporters.iso_code2 = sandbox_table.trading_partner
      JOIN geo_entities AS importers ON
        importers.id = ' || aru.trading_country_id;
    END IF;
    sql := sql ||
      '
      JOIN trade_codes AS terms ON sandbox_table.term_code = terms.code
        AND terms.type = ''Term''
      LEFT JOIN trade_codes AS sources ON sandbox_table.source_code = sources.code
        AND sources.type = ''Source''
      LEFT JOIN trade_codes AS units ON sandbox_table.unit_code = units.code
        AND units.type = ''Unit''
      LEFT JOIN trade_codes AS purposes ON sandbox_table.purpose_code = purposes.code
        AND purposes.type = ''Purpose''
      LEFT JOIN geo_entities AS origins ON origins.iso_code2 = sandbox_table.country_of_origin
      RETURNING *
    ) SELECT * FROM inserted_shipments';

  EXECUTE sql;

  GET DIAGNOSTICS inserted_shipments = ROW_COUNT;
  RAISE INFO '[%] Inserted % shipments out of %', table_name, inserted_shipments, total_shipments;
  IF inserted_shipments < total_shipments THEN
    RETURN -1;
  END IF;

  FOREACH permit_type IN ARRAY ARRAY['export', 'import', 'origin'] LOOP

    sql := 'WITH split_permits AS (
      SELECT id, SQUISH(regexp_split_to_table(' || permit_type || '_permit, ''[:;,]'')) AS permit
      FROM '|| table_name || '
    )
    INSERT INTO trade_shipment_' || permit_type || '_permits(
        trade_shipment_id,
        trade_permit_id,
        created_at,
        updated_at
      )
      SELECT DISTINCT ON (1,2)
        shipments_for_submit.id,
        trade_permits.id,
        current_date,
        current_date
      FROM '|| table_name || '_for_submit shipments_for_submit
      INNER JOIN split_permits
        ON split_permits.id = shipments_for_submit.sandbox_id
      INNER JOIN trade_permits
        ON trade_permits.number = split_permits.permit';

    EXECUTE sql;

    GET DIAGNOSTICS inserted_rows = ROW_COUNT;
    RAISE INFO '[%] Inserted % shipment % permits', table_name, inserted_rows, permit_type;

  END LOOP;

  sql := 'UPDATE trade_shipments SET sandbox_id = NULL
  WHERE trade_shipments.trade_annual_report_upload_id = ' || aru.id;
  EXECUTE sql;
  RETURN inserted_shipments;
END;
$$;

COMMENT ON FUNCTION copy_transactions_from_sandbox_to_shipments(annual_report_upload_id INTEGER) IS
  'Procedure to copy transactions from sandbox to shipments. Returns the number of rows copied if success, 0 if failure.'