class AddCreatedByIdToTaxonRelationships < ActiveRecord::Migration
  def change
    add_column :taxon_relationships, :created_by_id, :integer
  end
end
