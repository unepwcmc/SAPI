class AddIsCurrentToEvent < ActiveRecord::Migration
  def change
    add_column :events, :is_current, :boolean, :null => false, :default => false
  end
end
