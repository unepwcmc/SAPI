class AddUpdatedByIdToTaxonConceptReferences < ActiveRecord::Migration
  def change
    add_column :taxon_concept_references, :updated_by_id, :integer
  end
end
