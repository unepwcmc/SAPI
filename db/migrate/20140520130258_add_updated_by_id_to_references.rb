class AddUpdatedByIdToReferences < ActiveRecord::Migration
  def change
    add_column :references, :updated_by_id, :integer
  end
end
