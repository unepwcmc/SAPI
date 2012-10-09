class AddIsCurrentToListingChanges < ActiveRecord::Migration
  def change
    add_column :listing_changes, :is_current, :boolean, :null => false, :default => false
  end
end
