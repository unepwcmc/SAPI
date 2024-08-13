class UpdateTradeShipmentsCitesSuspensionsView < ActiveRecord::Migration[4.2]
  def up
    execute 'DROP MATERIALIZED VIEW IF EXISTS trade_shipments_cites_suspensions_mview CASCADE'
    execute 'DROP VIEW IF EXISTS trade_shipments_cites_suspensions_view'

    execute "CREATE VIEW trade_shipments_cites_suspensions_view AS #{view_sql('20180713123936', 'trade_shipments_cites_suspensions_view')}"
    execute 'CREATE MATERIALIZED VIEW trade_shipments_cites_suspensions_mview AS SELECT * FROM trade_shipments_cites_suspensions_view'
  end

  def down
    execute 'DROP MATERIALIZED VIEW IF EXISTS trade_shipments_cites_suspensions_mview CASCADE'
    execute 'DROP VIEW IF EXISTS trade_shipments_cites_suspensions_view'
  end
end
