class RemoveYearConstraintFromTradePlusShipmentsView < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS trade_plus_shipments_view CASCADE"
    execute "CREATE VIEW trade_plus_shipments_view AS #{view_sql('20200206150700', 'trade_plus_shipments_view')}"
    execute "CREATE VIEW trade_plus_group_view AS #{view_sql('20191030154249', 'trade_plus_group_view')}"
    execute "CREATE VIEW trade_plus_formatted_data_view AS #{view_sql('20191209215129', 'trade_plus_formatted_data_view')}"
    execute "CREATE VIEW trade_plus_complete_view AS #{view_sql('20191209215129', 'trade_plus_complete_view')}"
    execute "CREATE MATERIALIZED VIEW trade_plus_complete_mview AS SELECT * FROM trade_plus_complete_view"
  end

  def down
    execute "DROP VIEW IF EXISTS trade_plus_shipments_view CASCADE"
    execute "CREATE VIEW trade_plus_shipments_view AS #{view_sql('20191029163326', 'trade_plus_shipments_view')}"
    execute "CREATE VIEW trade_plus_group_view AS #{view_sql('20191030154249', 'trade_plus_group_view')}"
    execute "CREATE VIEW trade_plus_formatted_data_view AS #{view_sql('20191030154249', 'trade_plus_formatted_data_view')}"
    execute "CREATE VIEW trade_plus_complete_view AS #{view_sql('20191023141810', 'trade_plus_complete_view')}"
    execute "CREATE MATERIALIZED VIEW trade_plus_complete_mview AS SELECT * FROM trade_plus_complete_view"
  end
end
