CREATE OR REPLACE FUNCTION rebuild_trade_plus_complete_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    DROP MATERIALIZED VIEW IF EXISTS trade_plus_complete_mview CASCADE;

    RAISE INFO 'Creating Trade Plus complete materialized view';
    CREATE MATERIALIZED VIEW trade_plus_complete_mview AS
    SELECT *
    FROM trade_plus_complete_view;
  END;
  $$;
