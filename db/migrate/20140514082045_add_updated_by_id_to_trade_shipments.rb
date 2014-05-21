class AddUpdatedByIdToTradeShipments < ActiveRecord::Migration
  def change
    add_column :trade_shipments, :updated_by_id, :integer
  end
end
