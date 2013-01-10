class AddTaxonomicPositionToTaxonConcepts < ActiveRecord::Migration
  def change
    add_column :taxon_concepts, :taxonomic_position, :string, :null => false, :default => '0'
  end
end
