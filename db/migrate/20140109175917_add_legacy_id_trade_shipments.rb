class AddLegacyIdTradeShipments < ActiveRecord::Migration
  def change
    add_column :trade_shipments, :legacy_id, :integer
  end
end
