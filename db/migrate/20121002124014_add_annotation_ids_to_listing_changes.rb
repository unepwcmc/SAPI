class AddAnnotationIdsToListingChanges < ActiveRecord::Migration
  def change
    add_column :listing_changes, :specific_annotation_id, :integer
    add_column :listing_changes, :generic_annotation_id, :integer
    add_foreign_key "listing_changes", "annotations", :name => "listing_changes_specific_annotation_id_fk", :column => :specific_annotation_id
    add_foreign_key "listing_changes", "annotations", :name => "listing_changes_generic_annotation_id_fk", :column => :generic_annotation_id
  end
end
