class RenameIsInterDesignationalToIsInterdesignationalOnTaxonRelationshipTypes < ActiveRecord::Migration
  def change
    rename_column :taxon_relationship_types, :is_inter_designational, :is_interdesignational
  end
end
