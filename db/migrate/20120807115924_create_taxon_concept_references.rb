class CreateTaxonConceptReferences < ActiveRecord::Migration
  def change
    create_table :taxon_concept_references do |t|
      t.integer :taxon_concept_id, :null => false
      t.integer :reference_id, :null => false
      t.boolean :is_author, :null => false, :default => false
    end
    add_foreign_key :taxon_concept_references, :taxon_concepts, :name => :taxon_concept_references_taxon_concept_id_fk
    add_foreign_key :taxon_concept_references, :references, :name => :taxon_concept_references_reference_id_fk
  end
end
