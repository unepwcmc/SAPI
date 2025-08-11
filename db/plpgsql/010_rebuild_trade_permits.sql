CREATE OR REPLACE FUNCTION public.normalise_trade_permit(
  original_permit TEXT
) RETURNS TEXT LANGUAGE SQL IMMUTABLE
AS $normalise_trade_permit$
  SELECT UPPER(squish_null(original_permit));
$normalise_trade_permit$;

CREATE OR REPLACE FUNCTION public.rebuild_trade_permits()
  RETURNS VOID LANGUAGE PLPGSQL AS $rebuild_trade_permits$
BEGIN
  -- NOTE: you probably don't want to do this on your local machine, since this
  -- causes a full-table rewrite of the very large (>4GB) trade_shipments
  RAISE NOTICE 'STARTED rebuild_trade_permits (txn % +%)',
    transaction_timestamp() txn_start,
    clock_timestamp() - transaction_timestamp() as txn_duration;

  -- No CASCADE here because we don't expect it to have dependants that need
  -- recreating.
  DROP TABLE trade_permits;

  CREATE TEMP TABLE "tmp_shipment_permits" (
    id SERIAL PRIMARY KEY,
    "trade_shipment_id" BIGINT NOT NULL,
    "permit_type" TEXT NOT NULL,
    "permit" TEXT NOT NULL
  ) ON COMMIT DROP;

  INSERT INTO tmp_shipment_permits (
    trade_shipment_id, permit_type, permit
  )
  SELECT
    *
  FROM (
    SELECT
      id trade_shipment_id,
      'import' permit_type,
      UPPER(
        squish_null(
          regexp_split_to_table(
            import_permit_number,
            ';'
          )
        )
      ) permit
    FROM trade_shipments
  UNION ALL
    SELECT
      id trade_shipment_id,
      'export' permit_type,
      UPPER(
        squish_null(
          regexp_split_to_table(
            export_permit_number,
            ';'
          )
        )
      ) permit
    FROM trade_shipments
  UNION ALL
    SELECT
      id trade_shipment_id,
      'origin' permit_type,
      UPPER(
        squish_null(
          regexp_split_to_table(
            origin_permit_number,
            ';'
          )
        )
      ) permit
    FROM trade_shipments
  ) p WHERE permit IS NOT NULL;

  RAISE NOTICE 'INSERTED INTO "tmp_shipment_permits" (txn % +%)',
    transaction_timestamp() txn_start,
    clock_timestamp() - transaction_timestamp() as txn_duration;

  CREATE TABLE "trade_permits" (
    "id" SERIAL,
    "number" CHARACTER VARYING(255) NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT transaction_timestamp(),
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT transaction_timestamp()
  );

  CREATE INDEX ON tmp_shipment_permits (trade_shipment_id);
  CREATE INDEX ON tmp_shipment_permits (permit);

  INSERT INTO "trade_permits" ("number")
  SELECT DISTINCT(permit) FROM tmp_shipment_permits;

  RAISE NOTICE 'INSERTED INTO "trade_permits" (txn % +%)',
    transaction_timestamp() txn_start,
    clock_timestamp() - transaction_timestamp() as txn_duration;

  -- Create the PK constraint after populating, because that's faster.
  ALTER TABLE ONLY public.trade_permits ADD CONSTRAINT trade_permits_pkey PRIMARY KEY ("id");
  CREATE UNIQUE INDEX trade_permits_number_idx ON public.trade_permits USING btree (upper((number)::text) varchar_pattern_ops);
  CREATE INDEX trade_permits_number_trigm_idx ON public.trade_permits USING gin (upper((number)::text) public.gin_trgm_ops);

  CREATE UNIQUE INDEX tmp_trade_permits_number ON trade_permits ("number");
  CREATE INDEX tmp_trade_permits_number_id ON trade_permits ("number", "id");

  RAISE NOTICE 'CREATED INDEXES ON trade_permits (txn % +%)',
    transaction_timestamp() txn_start,
    clock_timestamp() - transaction_timestamp() as txn_duration;

  CREATE TEMP TABLE "to_update_shipments" AS
    SELECT trade_shipment_id,
      array_agg(trade_permits.id ORDER BY trade_permits.id) FILTER(WHERE permit_type = 'import') AS import_permits_ids,
      array_agg(trade_permits.id ORDER BY trade_permits.id) FILTER(WHERE permit_type = 'origin') AS export_permits_ids,
      array_agg(trade_permits.id ORDER BY trade_permits.id) FILTER(WHERE permit_type = 'export') AS origin_permits_ids
    FROM tmp_shipment_permits
    JOIN trade_permits
      ON tmp_shipment_permits.permit = trade_permits.number
    GROUP BY trade_shipment_id;

  RAISE NOTICE 'CREATED to_update_shipments (txn % +%)',
    transaction_timestamp() txn_start,
    clock_timestamp() - transaction_timestamp() as txn_duration;

  CREATE UNIQUE INDEX ON to_update_shipments (trade_shipment_id);

  RAISE NOTICE 'CREATED UNIQUE INDEX ON to_update_shipments (txn % +%)',
    transaction_timestamp() txn_start,
    clock_timestamp() - transaction_timestamp() as txn_duration;

  ANALYSE trade_shipments;
  RAISE NOTICE 'ANALYSED trade_shipments (txn % +%)',
    transaction_timestamp() txn_start,
    clock_timestamp() - transaction_timestamp() as txn_duration;

  ANALYSE to_update_shipments;
  RAISE NOTICE 'ANALYSED to_update_shipments (txn % +%)',
    transaction_timestamp() txn_start,
    clock_timestamp() - transaction_timestamp() as txn_duration;

  -- Do not update the index on each row update, instead, hold off and update
  -- the indexes at the end.
  UPDATE pg_index
  SET
    indisready = FALSE,
    indisvalid = FALSE
  WHERE indrelid = (
    SELECT oid
    FROM pg_class
    WHERE relname = 'trade_shipments'
  ) AND NOT indisprimary;

  DO $do$
  DECLARE
    -- a million rows at a time
    batch_size INTEGER := 1e6;
    batch_offset INTEGER := 0;
    max_id INTEGER := 0;
  BEGIN
    SELECT max("id") INTO max_id FROM trade_shipments;

    LOOP
      WITH to_update_slice AS (
        SELECT * FROM to_update_shipments
        WHERE trade_shipment_id > batch_offset
          AND trade_shipment_id <= batch_offset + batch_size
        ORDER BY trade_shipment_id
      )
      UPDATE trade_shipments SET
        import_permits_ids = to_update_slice.import_permits_ids,
        export_permits_ids = to_update_slice.export_permits_ids,
        origin_permits_ids = to_update_slice.origin_permits_ids
      FROM to_update_slice
      WHERE to_update_slice.trade_shipment_id = trade_shipments.id;

      batch_offset := batch_offset + batch_size;

      RAISE NOTICE 'UPDATING trade_shipments progress 1 .. % .. % (txn % +%)',
        batch_offset, max_id,
        transaction_timestamp() txn_start,
        clock_timestamp() - transaction_timestamp() as txn_duration;

      EXIT WHEN batch_offset > max_id;
    END LOOP;
  END $do$;

  RAISE NOTICE 'UPDATED trade_shipments (txn % +%)',
    transaction_timestamp() txn_start,
    clock_timestamp() - transaction_timestamp() as txn_duration;

  REINDEX TABLE trade_shipments;

  RAISE NOTICE 'REINDEXED trade_shipments (txn % +%)',
    transaction_timestamp() txn_start,
    clock_timestamp() - transaction_timestamp() as txn_duration;

  DROP INDEX tmp_trade_permits_number;
  DROP INDEX tmp_trade_permits_number_id;

  DROP TABLE to_update_shipments CASCADE;
  DROP TABLE tmp_shipment_permits CASCADE;

  RAISE NOTICE 'DROPPED temp tables and indexes (txn % +%)',
    transaction_timestamp() txn_start,
    clock_timestamp() - transaction_timestamp() as txn_duration;
END $rebuild_trade_permits$;

