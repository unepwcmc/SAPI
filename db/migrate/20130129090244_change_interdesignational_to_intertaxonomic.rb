class ChangeInterdesignationalToIntertaxonomic < ActiveRecord::Migration
  def change
    rename_column :taxon_relationship_types, :is_interdesignational, :is_intertaxonomic
  end
end
