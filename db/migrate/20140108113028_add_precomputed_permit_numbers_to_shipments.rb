class AddPrecomputedPermitNumbersToShipments < ActiveRecord::Migration
  def change
    add_column :trade_shipments, :import_permit_number, :string
    add_column :trade_shipments, :export_permit_number, :string
    add_column :trade_shipments, :origin_permit_number, :string
    add_column :trade_shipments, :permits_ids, 'INTEGER[]' #one column for them all
  end
end
