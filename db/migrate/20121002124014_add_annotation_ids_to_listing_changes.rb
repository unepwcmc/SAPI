class AddAnnotationIdsToListingChanges < ActiveRecord::Migration
  def change
    add_column :listing_changes, :annotation_id, :integer
    add_column :annotations, :listing_change_id, :integer
    add_foreign_key "listing_changes", "annotations", :name => "listing_changes_annotation_id_fk"
    add_foreign_key "annotations", "listing_changes", :name => "annotations_listing_changes_id_fk"
  end
end
