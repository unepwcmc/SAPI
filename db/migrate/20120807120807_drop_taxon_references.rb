class DropTaxonReferences < ActiveRecord::Migration
  def change
    drop_table :taxon_references
  end
end
