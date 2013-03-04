class AddExplicitChangeToListingChanges < ActiveRecord::Migration
  def change
    add_column :listing_changes, :explicit_change, :boolean, :default => true
  end
end
