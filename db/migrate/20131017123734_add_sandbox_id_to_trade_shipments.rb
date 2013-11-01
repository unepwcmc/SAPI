class AddSandboxIdToTradeShipments < ActiveRecord::Migration
  def change
    add_column :trade_shipments, :sandbox_id, :integer
  end
end
