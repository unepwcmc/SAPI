CREATE OR REPLACE FUNCTION rebuild_permit_numbers() RETURNS void
  LANGUAGE plpgsql
  AS $$
    DECLARE
      total_cnt INT;
      processed_cnt INT;
      batch_size INT;
    BEGIN
    processed_cnt := 0;
    batch_size := 1000000;
    SELECT COUNT(*) INTO total_cnt FROM trade_shipments;
    RAISE INFO 'Rebuilding permit number for % shipments in batches of %', total_cnt, batch_size;

    LOOP
      EXIT WHEN processed_cnt >= total_cnt;

      WITH shipments_with_import_permits AS (
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
      ), shipments_for_update AS (
      SELECT shipments.id, import_permits_ids || export_permits_ids || origin_permits_ids AS permits_ids,
        si.import_permit_number, se.export_permit_number, so.origin_permit_number
      FROM trade_shipments shipments
      LEFT JOIN shipments_with_import_permits si ON shipments.id = si.trade_shipment_id
      LEFT JOIN shipments_with_export_permits se ON shipments.id = se.trade_shipment_id
      LEFT JOIN shipments_with_origin_permits so ON shipments.id = so.trade_shipment_id
      LIMIT 10000 OFFSET processed_cnt
      )
      UPDATE trade_shipments
      SET (permits_ids, import_permit_number, export_permit_number, origin_permit_number) =
      (s.permits_ids, s.import_permit_number, s.export_permit_number, s.origin_permit_number)
      FROM shipments_for_update s
      WHERE s.id = trade_shipments.id;

      processed_cnt := processed_cnt + batch_size;
      RAISE INFO 'Processed % of %', processed_cnt, total_cnt;
    END LOOP;

    END;
  $$;

COMMENT ON FUNCTION rebuild_permit_numbers() IS 'Procedure to rebuild permit numbers pre-computed columns in shipments.';
