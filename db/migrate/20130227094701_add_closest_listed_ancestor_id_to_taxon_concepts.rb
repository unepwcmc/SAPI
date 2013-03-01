class AddClosestListedAncestorIdToTaxonConcepts < ActiveRecord::Migration
  def change
    add_column :taxon_concepts, :closest_listed_ancestor_id, :integer
      add_foreign_key "taxon_concepts", "taxon_concepts",
        :name => "taxon_concepts_closest_listed_ancestor_id_fk",
        :column => "closest_listed_ancestor_id"
  end
end
