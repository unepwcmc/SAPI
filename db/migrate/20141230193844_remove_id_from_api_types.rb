class RemoveIdFromApiTypes < ActiveRecord::Migration
  def change
    execute "DROP VIEW IF EXISTS api_cites_listing_changes_view"
    execute "DROP VIEW IF EXISTS api_cites_suspensions_view"
    execute "DROP VIEW IF EXISTS api_cites_quotas_view"
    execute "DROP VIEW IF EXISTS api_eu_listing_changes_view"
    execute "DROP VIEW IF EXISTS api_eu_decisions_view"

    execute <<-SQL
      DROP TYPE api_geo_entity;
      CREATE TYPE api_geo_entity AS (
        iso_code2 TEXT,
        name TEXT,
        type TEXT
      );
      DROP TYPE api_trade_code;
      CREATE TYPE api_trade_code AS (
        code TEXT,
        name TEXT
      );
      DROP TYPE api_eu_decision_type;
      CREATE TYPE api_eu_decision_type AS (
        name TEXT,
        description TEXT,
        type TEXT
      );
    SQL

    execute "CREATE VIEW api_cites_listing_changes_view AS #{view_sql('20141230193844', 'api_cites_listing_changes_view')}"
    execute "CREATE VIEW api_cites_suspensions_view AS #{view_sql('20141230193844', 'api_cites_suspensions_view')}"
    execute "CREATE VIEW api_cites_quotas_view AS #{view_sql('20141230193844', 'api_cites_quotas_view')}"
    execute "CREATE VIEW api_eu_listing_changes_view AS #{view_sql('20141230193844', 'api_eu_listing_changes_view')}"
    execute "CREATE VIEW api_eu_decisions_view AS #{view_sql('20141230193844', 'api_eu_decisions_view')}"

20141230193844
  end
end
