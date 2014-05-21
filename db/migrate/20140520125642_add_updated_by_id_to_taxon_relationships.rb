class AddUpdatedByIdToTaxonRelationships < ActiveRecord::Migration
  def change
    add_column :taxon_relationships, :updated_by_id, :integer
  end
end
