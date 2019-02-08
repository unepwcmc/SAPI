CREATE OR REPLACE FUNCTION rebuild_trade_shipments_appendix_i_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    DROP MATERIALIZED VIEW IF EXISTS trade_shipments_appendix_i_mview CASCADE;

    RAISE INFO 'Creating appendix I materialized view';
    CREATE MATERIALIZED VIEW trade_shipments_appendix_i_mview AS
    SELECT *
    FROM trade_shipments_appendix_i_view;
  END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_trade_shipments_mandatory_quotas_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    DROP MATERIALIZED VIEW IF EXISTS trade_shipments_mandatory_quotas_mview CASCADE;
    RAISE INFO 'Creating mandatory quotas materialized view';
    CREATE MATERIALIZED VIEW trade_shipments_mandatory_quotas_mview AS
    SELECT *
    FROM trade_shipments_mandatory_quotas_view;
  END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_trade_shipments_cites_suspensions_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    DROP MATERIALIZED VIEW IF EXISTS trade_shipments_cites_suspensions_mview CASCADE;
    RAISE INFO 'Creating CITES suspensions materialized view';
    CREATE MATERIALIZED VIEW trade_shipments_cites_suspensions_mview AS
    SELECT *
    FROM trade_shipments_cites_suspensions_view;

  END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_non_compliant_shipments_view() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    DROP VIEW IF EXISTS non_compliant_shipments_view CASCADE;
    RAISE INFO 'Creating non compliant shipments view';
    CREATE VIEW non_compliant_shipments_view AS (
      SELECT id, year, appendix, taxon_concept_id,
             author_year,
             name_status,
             taxon_name,
             phylum_id,
             class_id,
             class_name,
             order_id,
             order_name,
             family_id,
             family_name,
             genus_id,
             genus_name,
             term_id,
             term,
             importer_reported_quantity,
             exporter_reported_quantity,
             unit_id,
             unit,
             exporter_id,
             exporter_iso,
             exporter,
             importer_id,
             importer_iso,
             importer,
             origin,
             purpose_id,
             purpose,
             source_id,
             source,
             import_permits,
             export_permits,
             origin_permits,
             import_permit,
             export_permit,
             origin_permit,
             rank_id,
             rank_name,
             issue_type::text
      FROM trade_shipments_appendix_i_mview

      UNION ALL

      SELECT id, year, appendix, taxon_concept_id,
             author_year,
             name_status,
             taxon_name,
             phylum_id,
             class_id,
             class_name,
             order_id,
             order_name,
             family_id,
             family_name,
             genus_id,
             genus_name,
             term_id,
             term,
             importer_reported_quantity,
             exporter_reported_quantity,
             unit_id,
             unit,
             exporter_id,
             exporter_iso,
             exporter,
             importer_id,
             importer_iso,
             importer,
             origin,
             purpose_id,
             purpose,
             source_id,
             source,
             import_permits,
             export_permits,
             origin_permits,
             import_permit,
             export_permit,
             origin_permit,
             rank_id,
             rank_name,
             issue_type::text
      FROM trade_shipments_mandatory_quotas_mview

      UNION ALL

      SELECT id, year, appendix, taxon_concept_id,
             author_year,
             name_status,
             taxon_name,
             phylum_id,
             class_id,
             class_name,
             order_id,
             order_name,
             family_id,
             family_name,
             genus_id,
             genus_name,
             term_id,
             term,
             importer_reported_quantity,
             exporter_reported_quantity,
             unit_id,
             unit,
             exporter_id,
             exporter_iso,
             exporter,
             importer_id,
             importer_iso,
             importer,
             origin,
             purpose_id,
             purpose,
             source_id,
             source,
             import_permits,
             export_permits,
             origin_permits,
             import_permit,
             export_permit,
             origin_permit,
             rank_id,
             rank_name,
             issue_type::text
      FROM trade_shipments_cites_suspensions_mview
    );
  END;
  $$;
