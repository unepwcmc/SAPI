class RemoveClosestListedAncestorIdFromTaxonConcepts < ActiveRecord::Migration
  def change
  	remove_column :taxon_concepts, :closest_listed_ancestor_id
  end
end
