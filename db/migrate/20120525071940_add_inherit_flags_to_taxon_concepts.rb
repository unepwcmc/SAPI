class AddInheritFlagsToTaxonConcepts < ActiveRecord::Migration
  def change
    add_column :taxon_concepts, :inherit_distribution, :boolean, :null => false, :default => true
    add_column :taxon_concepts, :inherit_legislation, :boolean, :null => false, :default => true
    add_column :taxon_concepts, :inherit_references, :boolean, :null => false, :default => true
  end
end
