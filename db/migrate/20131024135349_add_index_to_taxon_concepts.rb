class AddIndexToTaxonConcepts < ActiveRecord::Migration
  def change
  	add_index :taxon_concepts, :full_name #this index is for exact matches in trade validations
  end
end
