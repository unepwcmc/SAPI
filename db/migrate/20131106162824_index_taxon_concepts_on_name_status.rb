class IndexTaxonConceptsOnNameStatus < ActiveRecord::Migration
  def change
    add_index :taxon_concepts, :name_status
  end
end
