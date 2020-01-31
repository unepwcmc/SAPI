CREATE OR REPLACE FUNCTION rebuild_trade_plus_complete_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    DROP MATERIALIZED VIEW IF EXISTS trade_plus_complete_mview CASCADE;

    RAISE INFO 'Creating Trade Plus complete materialized view';
    CREATE MATERIALIZED VIEW trade_plus_complete_mview AS
    SELECT *
    FROM trade_plus_complete_view;

    ALTER TABLE trade_plus_complete_mview ADD PRIMARY KEY (id);

    CREATE INDEX "index_trade_plus_complete_mview_on_appendix" ON trade_plus_complete_mview USING btree (appendix);
    CREATE INDEX "index_trade_plus_complete_mview_on_origin_id" ON trade_plus_complete_mview USING btree (origin_id);
    CREATE INDEX "index_trade_plus_complete_mview_on_origin_iso" ON trade_plus_complete_mview USING btree (origin_iso);
    CREATE INDEX "index_trade_plus_complete_mview_on_exporter_id" ON trade_plus_complete_mview USING btree (exporter_id);
    CREATE INDEX "index_trade_plus_complete_mview_on_exporter_iso" ON trade_plus_complete_mview USING btree (exporter_iso);
    CREATE INDEX "index_trade_plus_complete_mview_on_importer_id" ON trade_plus_complete_mview USING btree (importer_id);
    CREATE INDEX "index_trade_plus_complete_mview_on_importer_iso" ON trade_plus_complete_mview USING btree (importer_iso);
    CREATE INDEX "index_trade_plus_complete_mview_on_purpose_id" ON trade_plus_complete_mview USING btree (purpose_id);
    CREATE INDEX "index_trade_plus_complete_mview_on_quantity" ON trade_plus_complete_mview USING btree (quantity);
    CREATE INDEX "index_trade_plus_complete_mview_on_taxon_id" ON trade_plus_complete_mview USING btree (taxon_id);
    CREATE INDEX "index_trade_plus_complete_mview_on_source_id" ON trade_plus_complete_mview USING btree (source_id);
    CREATE INDEX "index_trade_plus_complete_mview_on_term_id" ON trade_plus_complete_mview USING btree (term_id);
    CREATE INDEX "index_trade_plus_complete_mview_on_term_code" ON trade_plus_complete_mview USING btree (term_code);
    CREATE INDEX "index_trade_plus_complete_mview_on_term" ON trade_plus_complete_mview USING btree (term);
    CREATE INDEX "index_trade_plus_complete_mview_on_unit_id" ON trade_plus_complete_mview USING btree (unit_id);
    CREATE INDEX "index_trade_plus_complete_mview_on_unit_code" ON trade_plus_complete_mview USING btree (unit_code);
    CREATE INDEX "index_trade_plus_complete_mview_on_unit" ON trade_plus_complete_mview USING btree (unit);
    CREATE INDEX "index_trade_plus_complete_mview_on_year" ON trade_plus_complete_mview USING brin (year);
    CREATE INDEX "index_trade_plus_complete_mview_on_year_exporter_id" ON trade_plus_complete_mview USING brin (year, exporter_id);
    CREATE INDEX "index_trade_plus_complete_mview_on_year_importer_id" ON trade_plus_complete_mview USING brin (year, importer_id);
  END
  $$;
