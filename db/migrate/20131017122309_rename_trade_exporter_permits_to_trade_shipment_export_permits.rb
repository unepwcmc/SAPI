class RenameTradeExporterPermitsToTradeShipmentExportPermits < ActiveRecord::Migration
  def up
    remove_foreign_key :trade_exporter_permits, :name => "trade_exporter_permits_trade_permit_id_fk"
    remove_foreign_key :trade_exporter_permits, :name => "trade_exporter_permits_trade_shipment_id_fk"
    rename_table :trade_exporter_permits, :trade_shipment_export_permits
    add_foreign_key "trade_shipment_export_permits", "trade_permits", :name => "trade_shipment_export_permits_trade_permit_id_fk"
    add_foreign_key "trade_shipment_export_permits", "trade_shipments", :name => "trade_shipment_export_permits_trade_shipment_id_fk"
  end

  def down
    remove_foreign_key :trade_shipment_export_permits, :name => "trade_shipment_export_permits_trade_permit_id_fk"
    remove_foreign_key :trade_shipment_export_permits, :name => "trade_shipment_export_permits_trade_shipment_id_fk"
    rename_table :trade_shipment_export_permits, :trade_exporter_permits
    add_foreign_key "trade_exporter_permits", "trade_permits", :name => "trade_exporter_permits_trade_permit_id_fk"
    add_foreign_key "trade_exporter_permits", "trade_shipments", :name => "trade_exporter_permits_trade_shipment_id_fk"
  end
end
