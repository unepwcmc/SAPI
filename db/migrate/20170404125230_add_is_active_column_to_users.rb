class AddIsActiveColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_active, :boolean, default: true, null: false
  end
end
