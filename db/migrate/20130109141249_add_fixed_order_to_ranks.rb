class AddFixedOrderToRanks < ActiveRecord::Migration
  def change
    add_column :ranks, :fixed_order, :boolean, :null => false, :default => false
  end
end
