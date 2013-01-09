class ChangeParentIdToTaxonomicPositionInRanks < ActiveRecord::Migration
  def up
    remove_column :ranks, :parent_id
    add_column :ranks, :taxonomic_position, :string, :null => false, :default => '0'
  end

  def down
    add_column :ranks, :parent_id, :integer
    remove_column :ranks, :taxonomic_position
  end
end
