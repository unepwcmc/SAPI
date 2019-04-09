class AddEpixUserFieldsToShipments < ActiveRecord::Migration
  def up
    change_column_null :trade_shipments, :created_at, true
    change_column_null :trade_shipments, :updated_at, true
    add_column :trade_shipments, :epix_created_at, :timestamp
    add_column :trade_shipments, :epix_updated_at, :timestamp
    add_column :trade_shipments, :epix_created_by_id, :integer
    add_column :trade_shipments, :epix_updated_by_id, :integer
  end

  def down
    change_column_null :trade_shipments, :created_at, false
    change_column_null :trade_shipments, :updated_at, false
    remove_column :trade_shipments, :epix_created_at
    remove_column :trade_shipments, :epix_updated_at
    remove_column :trade_shipments, :epix_created_by_id
    remove_column :trade_shipments, :epix_updated_by_id
  end
end
