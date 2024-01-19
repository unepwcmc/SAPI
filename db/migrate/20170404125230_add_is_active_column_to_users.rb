class AddIsActiveColumnToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :is_active, :boolean, default: true, null: false
  end
end
