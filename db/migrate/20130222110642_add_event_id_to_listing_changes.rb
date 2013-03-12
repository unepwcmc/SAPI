class AddEventIdToListingChanges < ActiveRecord::Migration
  def change
    add_column :listing_changes, :event_id, :integer
    add_foreign_key :listing_changes, :events, :name => :listing_changes_event_id_fk
    add_index :listing_changes, [:event_id], :name => :index_listing_changes_on_event_id
  end
end
