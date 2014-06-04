class AddNotNullDefaultFalseOnIsManager < ActiveRecord::Migration
  def up
    execute 'UPDATE users SET is_manager = FALSE WHERE is_manager IS NULL'
    change_column :users, :is_manager, :boolean, :null => false, :default => false
  end

  def down
    change_column :users, :is_manager, :boolean, :null => true, :default => nil
  end
end
