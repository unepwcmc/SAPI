class AddSrgHistoryToEuDecisionsView < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TYPE api_srg_history AS (
        name TEXT,
        description TEXT
      );
    SQL
    execute "DROP VIEW IF EXISTS api_eu_decisions_view"
    execute "CREATE VIEW api_eu_decisions_view AS #{view_sql('20200514150717', 'api_eu_decisions_view')}"

    execute "DROP VIEW IF EXISTS eu_decisions_view"
    execute "CREATE VIEW eu_decisions_view AS #{view_sql('20200514150717', 'eu_decisions_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS api_eu_decisions_view"
    execute "CREATE VIEW api_eu_decisions_view AS #{view_sql('20150126161813', 'api_eu_decisions_view')}"

    execute "DROP VIEW IF EXISTS eu_decisions_view"
    execute "CREATE VIEW eu_decisions_view AS #{view_sql('20150210140508', 'eu_decisions_view')}"

    execute <<-SQL
      DROP TYPE api_srg_history
    SQL
  end
end
