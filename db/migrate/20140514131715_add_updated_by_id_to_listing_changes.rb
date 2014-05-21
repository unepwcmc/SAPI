class AddUpdatedByIdToListingChanges < ActiveRecord::Migration
  def change
    add_column :listing_changes, :updated_by_id, :integer
  end
end
