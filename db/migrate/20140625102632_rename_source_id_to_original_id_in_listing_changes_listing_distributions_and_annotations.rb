class RenameSourceIdToOriginalIdInListingChangesListingDistributionsAndAnnotations < ActiveRecord::Migration[4.2]
  def change
    rename_column :listing_changes, :source_id, :original_id
    rename_column :listing_distributions, :source_id, :original_id
    rename_column :annotations, :source_id, :original_id
  end
end
