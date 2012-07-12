class AddNotesToListingChanges < ActiveRecord::Migration
  def change
    add_column :listing_changes, :notes, :text
  end
end
