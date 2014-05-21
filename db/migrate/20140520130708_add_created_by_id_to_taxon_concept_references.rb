class AddCreatedByIdToTaxonConceptReferences < ActiveRecord::Migration
  def change
    add_column :taxon_concept_references, :created_by_id, :integer
  end
end
