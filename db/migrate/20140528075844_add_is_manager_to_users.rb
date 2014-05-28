class AddIsManagerToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_manager, :boolean
  end
end
