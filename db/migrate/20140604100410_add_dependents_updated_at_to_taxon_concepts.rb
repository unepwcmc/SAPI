class AddDependentsUpdatedAtToTaxonConcepts < ActiveRecord::Migration
  def change
    add_column :taxon_concepts, :dependents_updated_at, :datetime
  end
end
