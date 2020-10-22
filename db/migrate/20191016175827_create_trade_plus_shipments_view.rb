class CreateTradePlusShipmentsView < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS trade_plus_shipments_view"
    execute "CREATE VIEW trade_plus_shipments_view AS #{view_sql('20191029163326', 'trade_plus_shipments_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS trade_plus_shipments_view"
  end
end
