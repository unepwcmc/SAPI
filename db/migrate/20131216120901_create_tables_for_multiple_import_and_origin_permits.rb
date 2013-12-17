class CreateTablesForMultipleImportAndOriginPermits < ActiveRecord::Migration
  def change
    create_table :trade_shipment_import_permits do |t|
      t.integer  :trade_permit_id,   :null => false
      t.integer  :trade_shipment_id, :null => false
      t.timestamps
    end
    add_foreign_key :trade_shipment_import_permits, :trade_permits,
      :name => :trade_shipment_import_permits_trade_permit_id_fk
    add_foreign_key :trade_shipment_import_permits, :trade_shipments,
      :name => :trade_shipment_import_permits_trade_shipment_id_fk
    add_index :trade_shipment_import_permits, [:trade_shipment_id, :trade_permit_id],
      :name => :index_shipment_import_permits_on_shipment_id_and_permit_id, :unique => true

    create_table :trade_shipment_origin_permits do |t|
      t.integer  :trade_permit_id,   :null => false
      t.integer  :trade_shipment_id, :null => false
      t.timestamps
    end
    add_foreign_key :trade_shipment_origin_permits, :trade_permits,
      :name => :trade_shipment_origin_permits_trade_permit_id_fk
    add_foreign_key :trade_shipment_origin_permits, :trade_shipments,
      :name => :trade_shipment_origin_permits_trade_shipment_id_fk
    add_index :trade_shipment_origin_permits, [:trade_shipment_id, :trade_permit_id],
      :name => :index_shipment_origin_permits_on_shipment_id_and_permit_id, :unique => true
  end
end
