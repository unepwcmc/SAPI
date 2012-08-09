class AddIsStdRefToTaxonConceptReferences < ActiveRecord::Migration
  def change
    add_column :taxon_concept_references, :is_std_ref, :boolean, :null => false, :default => :false
  end
end
