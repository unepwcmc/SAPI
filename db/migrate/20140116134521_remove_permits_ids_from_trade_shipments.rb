class RemovePermitsIdsFromTradeShipments < ActiveRecord::Migration
  def up
    remove_column :trade_shipments, :permits_ids
  end

  def down
    add_column :trade_shipments, :permits_ids, :string
  end
end
