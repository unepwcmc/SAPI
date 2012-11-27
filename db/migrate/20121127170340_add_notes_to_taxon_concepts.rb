class AddNotesToTaxonConcepts < ActiveRecord::Migration
  def change
    add_column :taxon_concepts, :notes, :text
  end
end
