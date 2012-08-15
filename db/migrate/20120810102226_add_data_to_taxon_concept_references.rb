class AddDataToTaxonConceptReferences < ActiveRecord::Migration
  def change
    add_column :taxon_concept_references, :data, :hstore, :null => false, :default => ''
  end
end
