class AddImportPermitsIdsExportPermitsIdsOriginPermitsIdsToTradeShipments < ActiveRecord::Migration
  def change
    add_column :trade_shipments, :import_permits_ids, "CHARACTER VARYING[]"
    add_column :trade_shipments, :export_permits_ids, "CHARACTER VARYING[]"
    add_column :trade_shipments, :origin_permits_ids, "CHARACTER VARYING[]"
  end
end
