DROP FUNCTION IF EXISTS check_for_duplicates_in_shipments(INTEGER);
CREATE OR REPLACE FUNCTION check_for_duplicates_in_shipments(
  annual_report_upload_id INTEGER
  ) RETURNS INTEGER[]
  LANGUAGE plpgsql
  AS $$
  DECLARE
    table_name TEXT;
    duplicates_ids INTEGER[];
  BEGIN
    table_name = 'trade_sandbox_' || annual_report_upload_id;

    EXECUTE '
      WITH duplicates AS (
        SELECT DISTINCT sb.id
        FROM ' || table_name || ' AS sb
        JOIN geo_entities AS ge ON ge.iso_code2 = sb.trading_partner
        JOIN trade_shipments AS s ON sb.reported_taxon_concept_id = s.reported_taxon_concept_id
        AND sb.appendix = s.appendix AND sb.year::integer = s.year
        WHERE (
          ge.id = s.importer_id AND NOT s.reported_by_exporter AND
          sb.import_permit = s.import_permit_number
        )
        OR
        (
          ge.id = s.exporter_id AND s.reported_by_exporter AND
          sb.export_permit = s.export_permit_number
        )
      )

      SELECT ARRAY(SELECT id FROM duplicates);
    ' INTO duplicates_ids;

    RETURN duplicates_ids;

  END;
  $$;
