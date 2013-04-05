class AddIndexToTaxonConceptsMviewOnClosestListedAncestorId < ActiveRecord::Migration
  def change
  	add_index "taxon_concepts_mview", ["closest_listed_ancestor_id"],
  	  :name => "index_taxon_concepts_mview_on_closest_listed_ancestor_id"
  end
end
