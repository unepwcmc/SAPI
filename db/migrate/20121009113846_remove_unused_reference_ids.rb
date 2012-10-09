class RemoveUnusedReferenceIds < ActiveRecord::Migration
  def up
    remove_column :common_names, :reference_id
    remove_column :listing_changes, :reference_id
  end

  def down
    add_column :common_names, :reference_id, :integer
    add_column :listing_changes, :reference_id,:integer
  end
end
