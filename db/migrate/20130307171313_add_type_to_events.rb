class AddTypeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :type, :string, :null => false, :default => 'Event'
  end
end
