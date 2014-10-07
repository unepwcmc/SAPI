class AddInternalNotesToAllThings < ActiveRecord::Migration
  def change
    add_column :taxon_concepts, :internal_notes, :text
    add_column :listing_changes, :internal_notes, :text
    add_column :distributions, :internal_notes, :text
    add_column :trade_restrictions, :internal_notes, :text
  end
end
