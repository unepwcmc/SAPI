class RemoveListingChangeIdFromAnnotations < ActiveRecord::Migration
  def change
    remove_column :annotations, :listing_change_id
  end
end
