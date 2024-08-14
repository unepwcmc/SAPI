class FixCascadingOfCitesSuspensions < ActiveRecord::Migration[4.2]
  def up
    execute 'DROP VIEW IF EXISTS api_cites_suspensions_view'
    execute "CREATE VIEW api_cites_suspensions_view AS #{view_sql('20150512124835', 'api_cites_suspensions_view')}"
  end

  def down
    execute 'DROP VIEW IF EXISTS api_cites_suspensions_view'
    execute "CREATE VIEW api_cites_suspensions_view AS #{view_sql('20150114084537', 'api_cites_suspensions_view')}"
  end
end
