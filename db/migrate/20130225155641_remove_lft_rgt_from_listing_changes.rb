class RemoveLftRgtFromListingChanges < ActiveRecord::Migration
  def change
    remove_column :listing_changes, :lft
    remove_column :listing_changes, :rgt
  end
end
