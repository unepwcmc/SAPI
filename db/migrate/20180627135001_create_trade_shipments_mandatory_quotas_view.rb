class CreateTradeShipmentsMandatoryQuotasView < ActiveRecord::Migration
  def up
    execute "DROP MATERIALIZED VIEW IF EXISTS trade_shipments_mandatory_quotas_mview CASCADE"
    execute "DROP VIEW IF EXISTS trade_shipments_mandatory_quotas_view"

    execute "CREATE VIEW trade_shipments_mandatory_quotas_view AS #{view_sql('20180627135001', 'trade_shipments_mandatory_quotas_view')}"
    execute "CREATE MATERIALIZED VIEW trade_shipments_mandatory_quotas_mview AS SELECT * FROM trade_shipments_mandatory_quotas_view"
  end

  def down
    execute "DROP MATERIALIZED VIEW IF EXISTS trade_shipments_mandatory_quotas_mview CASCADE"
    execute "DROP VIEW IF EXISTS trade_shipments_mandatory_quotas_view"
  end
end
