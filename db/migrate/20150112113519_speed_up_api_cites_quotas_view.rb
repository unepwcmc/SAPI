class SpeedUpApiCitesQuotasView < ActiveRecord::Migration
  def change
    execute "DROP VIEW IF EXISTS api_cites_quotas_view"
    execute "CREATE VIEW api_cites_quotas_view AS #{view_sql('20150112113519', 'api_cites_quotas_view')}"
  end
end
