class DropIndexOnTaxonConceptsData < ActiveRecord::Migration
  def up
    remove_index "taxon_concepts", ["data"]
  end

  def down
    add_index "taxon_concepts", ["data"], :name => "index_taxon_concepts_on_data"
  end
end
