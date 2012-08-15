class RemoveIsAuthorFromTaxonConceptReferences < ActiveRecord::Migration
  def change
    remove_column :taxon_concept_references, :is_author
  end
end
