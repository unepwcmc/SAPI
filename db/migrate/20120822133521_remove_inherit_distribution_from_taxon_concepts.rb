class RemoveInheritDistributionFromTaxonConcepts < ActiveRecord::Migration
  def change
    remove_column :taxon_concepts, :inherit_distribution
  end
end
