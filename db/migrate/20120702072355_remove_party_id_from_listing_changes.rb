class RemovePartyIdFromListingChanges < ActiveRecord::Migration
  def change
    remove_column :listing_changes, :party_id
  end
end
