class AddIsBidirectionalToTaxonRelationshipTypes < ActiveRecord::Migration
  def change
    add_column :taxon_relationship_types, :is_bidirectional, :boolean, :default => false
  end
end
