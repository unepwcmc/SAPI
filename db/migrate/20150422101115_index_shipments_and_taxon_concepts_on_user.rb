class IndexShipmentsAndTaxonConceptsOnUser < ActiveRecord::Migration
  def up
    add_index :trade_shipments, [:created_by_id, :updated_by_id]
    add_index :taxon_concepts, [:created_by_id, :updated_by_id]
  end

  def down
    remove_index :trade_shipments, [:created_by_id, :updated_by_id]
    remove_index :taxon_concepts, [:created_by_id, :updated_by_id]
  end
end
