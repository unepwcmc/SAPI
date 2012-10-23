class AddIndexOnParentIdToTaxonConceptsMview < ActiveRecord::Migration
  def change
    add_index "taxon_concepts_mview", ["parent_id"], :name => "index_taxon_concepts_mview_on_parent_id"
  end
end
