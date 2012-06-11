class AddEffectiveAtToListingChanges < ActiveRecord::Migration
  def change
    add_column :listing_changes, :effective_at, :datetime, :null => false, :default => 'NOW()'
  end
end
