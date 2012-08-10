class RemoveInheritReferencesFromTaxonConcept < ActiveRecord::Migration
  def change
    remove_column :taxon_concepts, :inherit_references
  end
end
