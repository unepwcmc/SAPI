class DeleteIsStdRefFromTaxonConceptReferences < ActiveRecord::Migration
  def up
    remove_column :taxon_concept_references, :is_std_ref
  end
end
