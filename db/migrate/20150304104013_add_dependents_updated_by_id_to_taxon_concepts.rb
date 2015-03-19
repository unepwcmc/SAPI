class AddDependentsUpdatedByIdToTaxonConcepts < ActiveRecord::Migration
  def change
    add_column :taxon_concepts, :dependents_updated_by_id, :integer
    add_foreign_key :taxon_concepts, :users, name: 'taxon_concepts_dependents_updated_by_id_fk',
      column: 'dependents_updated_by_id'
  end
end
