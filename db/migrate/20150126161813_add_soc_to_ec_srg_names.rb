class AddSocToEcSrgNames < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS api_eu_decisions_view"
    execute "CREATE VIEW api_eu_decisions_view AS #{view_sql('20150126161813', 'api_eu_decisions_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS api_eu_decisions_view"
    execute "CREATE VIEW api_eu_decisions_view AS #{view_sql('20150121232443', 'api_eu_decisions_view')}"
  end
end
