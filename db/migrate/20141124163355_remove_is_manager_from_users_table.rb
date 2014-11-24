class RemoveIsManagerFromUsersTable < ActiveRecord::Migration
  def up
    remove_column :users, :is_manager
  end

  def down
    add_column :users, :is_manager, :boolean, default: false
  end
end