class AddIndicesToMaterializedListingChangesView < ActiveRecord::Migration
  def up
    execute "CREATE INDEX index_listing_changes_mview_on_taxon_concept_id ON listing_changes_mview (taxon_concept_id)"
  end
  def down
    execute "DROP INDEX index_listing_changes_mview_on_taxon_concept_id"
  end
end
