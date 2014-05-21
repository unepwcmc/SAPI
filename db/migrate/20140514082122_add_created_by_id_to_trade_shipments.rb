class AddCreatedByIdToTradeShipments < ActiveRecord::Migration
  def change
    add_column :trade_shipments, :created_by_id, :integer
  end
end
