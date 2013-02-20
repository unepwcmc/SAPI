class AddHashAnnotationIdToListingChanges < ActiveRecord::Migration
  def change
    add_column :listing_changes, :hash_annotation_id, :integer
    add_foreign_key :listing_changes, :annotations, :name => "listing_changes_hash_annotation_id_fk"
    add_index "listing_changes", ["hash_annotation_id"], :name => "index_listing_changes_on_hash_annotation_id"
  end
end
