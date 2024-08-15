class AddGeoEntityIdToSeveralViews < ActiveRecord::Migration[4.2]
  def up
    safety_assured do
      execute <<-SQL.squish
        DROP TYPE api_geo_entity CASCADE;
        CREATE TYPE api_geo_entity AS (
          id INT,
          iso_code2 TEXT,
          name TEXT,
          type TEXT
        );
      SQL

      execute 'DROP VIEW IF EXISTS api_cites_quotas_view;'
      execute 'DROP VIEW IF EXISTS api_cites_suspensions_view;'
      execute 'DROP VIEW IF EXISTS api_eu_decisions_view;'
      execute 'DROP VIEW IF EXISTS taxon_concepts_distributions_view;'

      execute "CREATE VIEW api_cites_listing_changes_view AS #{view_sql('20240815120000', 'api_cites_listing_changes_view')}"
      execute "CREATE VIEW api_cites_quotas_view AS #{view_sql('20240815120000', 'api_cites_quotas_view')}"
      execute "CREATE VIEW api_cites_suspensions_view AS #{view_sql('20240815120000', 'api_cites_suspensions_view')}"
      execute "CREATE VIEW api_eu_decisions_view AS #{view_sql('20240815120000', 'api_eu_decisions_view')}"
      execute "CREATE VIEW taxon_concepts_distributions_view AS #{view_sql('20240815120000', 'taxon_concepts_distributions_view')}"
    end
  end

  def down
    safety_assured do
      execute <<-SQL.squish
        DROP TYPE api_geo_entity CASCADE;
        CREATE TYPE api_geo_entity AS (
          iso_code2 TEXT,
          name TEXT,
          type TEXT
        );
      SQL

      execute 'DROP VIEW IF EXISTS api_cites_listing_changes_view;'
      execute 'DROP VIEW IF EXISTS api_cites_quotas_view;'
      execute 'DROP VIEW IF EXISTS api_cites_suspensions_view;'
      execute 'DROP VIEW IF EXISTS api_eu_decisions_view;'
      execute 'DROP VIEW IF EXISTS taxon_concepts_distributions_view;'

      execute "CREATE VIEW api_cites_listing_changes_view AS #{view_sql('20230509172742', 'api_cites_listing_changes_view')}"
      execute "CREATE VIEW api_cites_quotas_view AS #{view_sql('20221014151355', 'api_cites_quotas_view')}"
      execute "CREATE VIEW api_cites_suspensions_view AS #{view_sql('20240724113700', 'api_cites_suspensions_view')}"
      execute "CREATE VIEW api_eu_decisions_view AS #{view_sql('20220808165846', 'api_eu_decisions_view')}"
      execute "CREATE VIEW taxon_concepts_distributions_view AS #{view_sql('20141223141125', 'taxon_concepts_distributions_view')}"
    end
  end
end
