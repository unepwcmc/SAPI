class RemoveInheritLegislationFromTaxonConcepts < ActiveRecord::Migration
  def change
    remove_column :taxon_concepts, :inherit_legislation
  end
end
