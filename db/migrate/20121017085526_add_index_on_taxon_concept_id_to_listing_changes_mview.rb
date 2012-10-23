class AddIndexOnTaxonConceptIdToListingChangesMview < ActiveRecord::Migration
  def change
    add_index "listing_changes_mview", ["taxon_concept_id"], :name => "index_listing_changes_mview_on_taxon_concept_id"
  end
end
