class RemoveLftRgtFromTaxonConcepts < ActiveRecord::Migration
  def change
    remove_column :taxon_concepts, :lft
    remove_column :taxon_concepts, :rgt
  end
end
