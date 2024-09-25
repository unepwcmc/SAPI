class ReplaceTradeComplianceViewsForRailsTesting < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      execute "CREATE OR REPLACE VIEW trade_shipments_appendix_i_view AS #{view_sql('20240905153246', 'trade_shipments_appendix_i_view')}"
      execute "CREATE OR REPLACE VIEW trade_shipments_cites_suspensions_view AS #{view_sql('20240905155630', 'trade_shipments_cites_suspensions_view')}"
      execute "CREATE OR REPLACE VIEW trade_shipments_mandatory_quotas_view AS #{view_sql('20240905153745', 'trade_shipments_mandatory_quotas_view')}"
    end
  end
  def down
    safety_assured do
      execute "CREATE OR REPLACE VIEW trade_shipments_appendix_i_view AS #{view_sql('2023070615508', 'trade_shipments_appendix_i_view')}"
      execute "CREATE OR REPLACE VIEW trade_shipments_cites_suspensions_view AS #{view_sql('2023070616851', 'trade_shipments_cites_suspensions_view')}"
      execute "CREATE OR REPLACE VIEW trade_shipments_mandatory_quotas_view AS #{view_sql('2023070615541', 'trade_shipments_mandatory_quotas_view')}"
    end
  end
end
