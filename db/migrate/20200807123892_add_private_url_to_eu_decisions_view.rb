class AddPrivateUrlToEuDecisionsView < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TYPE api_eu_srg_event AS (
        name TEXT,
        date DATE,
        url TEXT,
        private_url TEXT
      );
    SQL
    execute "DROP VIEW IF EXISTS api_eu_decisions_view"
    execute "CREATE VIEW api_eu_decisions_view AS #{view_sql('20200807121747', 'api_eu_decisions_view')}"

  end

  def down
    execute "DROP VIEW IF EXISTS api_eu_decisions_view"
    execute "CREATE VIEW api_eu_decisions_view AS #{view_sql('20200514150717', 'api_eu_decisions_view')}"

    execute <<-SQL
      DROP TYPE api_eu_srg_event
    SQL
  end
end
