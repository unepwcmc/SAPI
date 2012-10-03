class RemoveNotesFromListingChanges < ActiveRecord::Migration
  def change
    remove_column :listing_changes, :notes
  end
end
