class ChangeIsManagerToRole < ActiveRecord::Migration
  def up
    add_column :users, :role, :string, default: 'default', null: false
    execute "UPDATE users SET role='admin' WHERE is_manager"
    execute "UPDATE users SET role='default' WHERE NOT is_manager"
    remove_column :users, :is_manager
  end

  def down
    add_column :users, :is_manager, :boolean, default: false, null: false
    execute "UPDATE users SET is_manager=TRUE WHERE role='admin'"
    execute "UPDATE users SET is_manage=FALSE WHERE role='default'"
    remove_column :users, :role
  end
end
