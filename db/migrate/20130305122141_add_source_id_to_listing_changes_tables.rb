class AddSourceIdToListingChangesTables < ActiveRecord::Migration
  def change
    add_column :annotations, :source_id, :integer
    add_column :listing_distributions, :source_id, :integer
    add_column :listing_changes, :source_id, :integer
  end
end
