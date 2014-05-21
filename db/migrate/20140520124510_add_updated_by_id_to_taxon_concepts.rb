class AddUpdatedByIdToTaxonConcepts < ActiveRecord::Migration
  def change
    add_column :taxon_concepts, :updated_by_id, :integer
  end
end
