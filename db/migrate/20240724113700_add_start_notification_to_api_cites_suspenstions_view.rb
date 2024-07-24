class AddStartNotificationToApiCitesSuspenstionsView < ActiveRecord::Migration[6.1]
  def up
    safety_assured do
      execute "DROP VIEW IF EXISTS api_cites_suspensions_view"
      execute "CREATE VIEW api_cites_suspensions_view AS #{view_sql('20240724113700', 'api_cites_suspensions_view')}"
    end
  end

  def down
    safety_assured do
      execute "DROP VIEW IF EXISTS api_cites_suspensions_view"
      execute "CREATE VIEW api_cites_suspensions_view AS #{view_sql('20221014151355', 'api_cites_suspensions_view')}"
    end
  end
end
