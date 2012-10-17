class AddIndexOnFullNameToTaxonConceptsMview < ActiveRecord::Migration
  def change
    add_index "taxon_concepts_mview", ["full_name"], :name => "index_taxon_concepts_mview_on_full_name"
  end
end
