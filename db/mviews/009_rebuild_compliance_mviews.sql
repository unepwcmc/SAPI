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
