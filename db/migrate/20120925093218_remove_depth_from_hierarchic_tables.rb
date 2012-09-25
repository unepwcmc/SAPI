class RemoveDepthFromHierarchicTables < ActiveRecord::Migration
  def change
    remove_column :taxon_concepts, :depth
    remove_column :listing_changes, :depth
  end
end
