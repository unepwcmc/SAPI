class AddIndexToTradeShipments < ActiveRecord::Migration
  def change
    add_index :trade_shipments, :sandbox_id
  end
end
