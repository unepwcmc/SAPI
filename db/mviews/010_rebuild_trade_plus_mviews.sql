CREATE OR REPLACE FUNCTION rebuild_trade_plus_complete_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    DROP MATERIALIZED VIEW IF EXISTS trade_plus_complete_mview CASCADE;
    -- Below is used for child taxa queries
    RAISE INFO 'Refreshing all taxon concepts and ancestors materialized view';
    REFRESH MATERIALIZED VIEW all_taxon_concepts_and_ancestors_mview;

    RAISE INFO 'Creating Trade Plus complete materialized view';
    CREATE MATERIALIZED VIEW trade_plus_complete_mview AS
    SELECT *
    FROM trade_plus_complete_view;

    PERFORM create_trade_plus_complete_mview_indexes();
  END
  $$;

CREATE OR REPLACE FUNCTION create_trade_plus_complete_mview_indexes() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    CREATE UNIQUE INDEX "index_trade_plus_complete_mview_on_id" ON trade_plus_complete_mview (id);
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
    CREATE INDEX "index_trade_plus_complete_mview_on_term_en" ON trade_plus_complete_mview USING btree (term_en);
    CREATE INDEX "index_trade_plus_complete_mview_on_unit_id" ON trade_plus_complete_mview USING btree (unit_id);
    CREATE INDEX "index_trade_plus_complete_mview_on_unit_code" ON trade_plus_complete_mview USING btree (unit_code);
    CREATE INDEX "index_trade_plus_complete_mview_on_unit_en" ON trade_plus_complete_mview USING btree (unit_en);
    CREATE INDEX "index_trade_plus_complete_mview_on_year" ON trade_plus_complete_mview USING brin (year);
    CREATE INDEX "index_trade_plus_complete_mview_on_year_exporter_id" ON trade_plus_complete_mview USING brin (year, exporter_id);
    CREATE INDEX "index_trade_plus_complete_mview_on_year_importer_id" ON trade_plus_complete_mview USING brin (year, importer_id);
    CREATE INDEX "index_trade_plus_complete_mview_on_year_origin_id" ON trade_plus_complete_mview USING brin (year, origin_id);
    CREATE INDEX "index_trade_plus_complete_mview_on_year_source_id" ON trade_plus_complete_mview USING brin (year, source_id);
    CREATE INDEX "index_trade_plus_complete_mview_on_year_purpose_id" ON trade_plus_complete_mview USING brin (year, purpose_id);
    CREATE INDEX "index_trade_plus_complete_mview_on_year_unit_id" ON trade_plus_complete_mview USING brin (year, unit_id);
    CREATE INDEX "index_trade_plus_complete_mview_on_year_term_id" ON trade_plus_complete_mview USING brin (year, term_id);
  END
  $$;
