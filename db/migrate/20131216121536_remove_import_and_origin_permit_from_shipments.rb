class RemoveImportAndOriginPermitFromShipments < ActiveRecord::Migration
  def up
    Trade::Shipment.all.each do |shipment|
      shipment.import_permit_ids << shipment.import_permit_id
      shipment.origin_permit_ids << shipment.country_of_origin_permit_id
    end

    execute "DROP VIEW IF EXISTS trade_shipments_view"

    remove_column :trade_shipments, :import_permit_id
    remove_column :trade_shipments, :country_of_origin_permit_id
  end

  def down
    add_column :trade_shipments, :import_permit_id, :integer
    add_column :trade_shipments, :country_of_origin_permit_id, :integer
    add_foreign_key "trade_shipments", "trade_permits", name: "trade_shipments_origin_permit_id_fk", column: "origin_permit_id"
    add_foreign_key "trade_shipments", "trade_permits", name: "trade_shipments_import_permit_id_fk", column: "import_permit_id"
    Trade::Shipment.all.each do |shipment|
      shipment.import_permit_id = shipment.import_permit_ids.first
      shipment.origin_permit_id = shipment.origin_permit_ids.first
    end
  end
end
