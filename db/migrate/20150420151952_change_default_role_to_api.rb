class ChangeDefaultRoleToApi < ActiveRecord::Migration
  def up
    change_column :users, :role, :text, null: false, default: 'api'
  end

  def down
    change_column :users, :role, :text, null: false, default: 'default'
  end
end
