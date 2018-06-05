class CreateTradeCitesSuspensionShipmentsView < ActiveRecord::Migration
  def up
    execute "DROP MATERIALIZED VIEW IF EXISTS trade_cites_suspension_shipments_mview CASCADE"
    execute "DROP VIEW IF EXISTS trade_cites_suspension_shipments_view"

    execute "CREATE VIEW trade_cites_suspension_shipments_view AS #{view_sql('20180601083440', 'trade_cites_suspension_shipments_view')}"
    execute "CREATE MATERIALIZED VIEW trade_cites_suspension_shipments_mview AS SELECT * FROM trade_cites_suspension_shipments_view"
  end

  def down
    execute "DROP MATERIALIZED VIEW IF EXISTS trade_cites_suspension_shipments_mview CASCADE"
    execute "DROP VIEW IF EXISTS trade_cites_suspension_shipments_view"
  end
end
