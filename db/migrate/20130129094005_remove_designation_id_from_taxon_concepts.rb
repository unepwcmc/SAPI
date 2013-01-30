class RemoveDesignationIdFromTaxonConcepts < ActiveRecord::Migration
  def change
    remove_column :taxon_concepts, :designation_id
  end
end
