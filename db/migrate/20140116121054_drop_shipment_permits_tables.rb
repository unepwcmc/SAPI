class DropShipmentPermitsTables < ActiveRecord::Migration
  def change
  	drop_table :trade_shipment_import_permits
  	drop_table :trade_shipment_export_permits
  	drop_table :trade_shipment_origin_permits
  end
end
