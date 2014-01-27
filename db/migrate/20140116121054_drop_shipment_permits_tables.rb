class DropShipmentPermitsTables < ActiveRecord::Migration
  def change
  	execute 'DROP VIEW IF EXISTS trade_shipments_view'
  	execute 'DROP TABLE IF EXISTS trade_shipment_import_permits'
  	execute 'DROP TABLE IF EXISTS trade_shipment_export_permits'
  	execute 'DROP TABLE IF EXISTS trade_shipment_origin_permits'
  end
end
