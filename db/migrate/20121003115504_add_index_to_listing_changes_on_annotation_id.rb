class AddIndexToListingChangesOnAnnotationId < ActiveRecord::Migration
  def up
    execute "CREATE INDEX index_listing_changes_on_annotation_id ON listing_changes (annotation_id)"
  end

  def down
    execute "DROP INDEX index_listing_changes_on_annotation_id"
  end
end
