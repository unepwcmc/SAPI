class AddIndexOnParentIdToTaxonConcepts < ActiveRecord::Migration
  def change
    add_index "taxon_concepts", ["parent_id"], :name => "index_taxon_concepts_on_parent_id"
  end
end
