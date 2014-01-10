class ChangeLegacyIdToLegacyShipmentNumberFromTradeShipments < ActiveRecord::Migration
  def change
    rename_column :trade_shipments, :legacy_id, :legacy_shipment_number
  end
end
