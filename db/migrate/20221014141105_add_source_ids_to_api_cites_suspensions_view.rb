class AddSourceIdsToApiCitesSuspensionsView < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS api_cites_suspensions_view"
    execute "CREATE VIEW api_cites_suspensions_view AS #{view_sql('20221014151355', 'api_cites_suspensions_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS api_cites_suspensions_view"
    execute "CREATE VIEW api_cites_suspensions_view AS #{view_sql('20150518122737', 'api_cites_suspensions_view')}"
  end
end
