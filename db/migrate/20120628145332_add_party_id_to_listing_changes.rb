class AddPartyIdToListingChanges < ActiveRecord::Migration
  def change
    add_column :listing_changes, :party_id, :integer
    add_foreign_key "listing_changes", "geo_entities", :name => "listing_changes_party_id_fk", :column => "party_id"
  end
end
