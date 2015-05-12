class FixCascadingOfQuotas < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS api_cites_quotas_view"
    execute "CREATE VIEW api_cites_quotas_view AS #{view_sql('20150512222755', 'api_cites_quotas_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS api_cites_quotas_view"
    execute "CREATE VIEW api_cites_quotas_view AS #{view_sql('20150114084537', 'api_cites_quotas_view')}"
  end
end
