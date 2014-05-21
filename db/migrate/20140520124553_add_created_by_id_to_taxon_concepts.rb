class AddCreatedByIdToTaxonConcepts < ActiveRecord::Migration
  def change
    add_column :taxon_concepts, :created_by_id, :integer
  end
end
