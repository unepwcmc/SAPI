class AddCreatedByIdToListingChanges < ActiveRecord::Migration
  def change
    add_column :listing_changes, :created_by_id, :integer
  end
end
