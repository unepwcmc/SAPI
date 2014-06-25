class RenameSourceIdToOriginalIdInListingChangesListingDistributionsAndAnnotations < ActiveRecord::Migration
  def change
    rename_column :listing_changes, :source_id, :original_id
    rename_column :listing_distributions, :source_id, :original_id
    rename_column :annotations, :source_id, :original_id
  end
end
