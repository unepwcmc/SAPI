class AddConstraintsToPermitsColumns < ActiveRecord::Migration
  def change
    change_column :trade_permits, :number, :string, :null => false
    add_index :trade_permits, [:geo_entity_id, :number], :unique => true
    change_column :trade_shipment_export_permits, :trade_permit_id, :integer, :null => false
    change_column :trade_shipment_export_permits, :trade_shipment_id, :integer, :null => false
    add_index :trade_shipment_export_permits, [:trade_shipment_id, :trade_permit_id],
      :unique => true, :name => :index_shipment_export_permits_on_shipment_id_and_permit_id
  end
end
