class AddFullyCoveredToTaxonConcepts < ActiveRecord::Migration
  def change
    add_column :taxon_concepts, :fully_covered, :boolean, :null => false, :default => true
  end
end
