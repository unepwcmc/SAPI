class AddNotInCites < ActiveRecord::Migration
  def change
    add_column :taxon_concepts, :not_in_cites, :boolean, :null => false, :default => false
  end
end
