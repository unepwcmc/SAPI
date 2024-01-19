class UpdateTradeShipmentsAppendixIView < ActiveRecord::Migration[4.2]
  def up
    execute "DROP MATERIALIZED VIEW IF EXISTS trade_shipments_appendix_i_mview CASCADE"
    execute "DROP VIEW IF EXISTS trade_shipments_appendix_i_view"

    execute "CREATE VIEW trade_shipments_appendix_i_view AS #{view_sql('20180705094119', 'trade_shipments_appendix_i_view')}"
    execute "CREATE MATERIALIZED VIEW trade_shipments_appendix_i_mview AS SELECT * FROM trade_shipments_appendix_i_view"
  end

  def down
    execute "DROP MATERIALIZED VIEW IF EXISTS trade_shipments_appendix_i_mview CASCADE"
    execute "DROP VIEW IF EXISTS trade_shipments_appendix_i_view"
  end
end
