class AddCreatedByIdToReferences < ActiveRecord::Migration
  def change
    add_column :references, :created_by_id, :integer
  end
end
