class AddIndexesToShipments < ActiveRecord::Migration
  def up
    Sapi::Indexes.drop_indexes_on_shipments
    Sapi::Indexes.create_indexes_on_shipments
  end
  def down
    Sapi::Indexes.drop_indexes_on_shipments
  end
end
