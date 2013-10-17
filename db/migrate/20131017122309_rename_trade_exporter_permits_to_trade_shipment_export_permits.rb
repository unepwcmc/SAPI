class RenameTradeExporterPermitsToTradeShipmentExportPermits < ActiveRecord::Migration
  def up
    rename_table :trade_exporter_permits, :trade_shipment_export_permits
  end

  def down
    rename_table :trade_shipment_export_permits, :trade_exporter_permits
  end
end
