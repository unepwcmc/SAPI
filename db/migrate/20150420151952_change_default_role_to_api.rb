class ChangeDefaultRoleToApi < ActiveRecord::Migration[4.2]
  def up
    change_column :users, :role, :text, null: false, default: 'api'
  end

  def down
    change_column :users, :role, :text, null: false, default: 'default'
  end
end
