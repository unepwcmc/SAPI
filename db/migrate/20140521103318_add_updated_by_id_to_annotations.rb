class AddUpdatedByIdToAnnotations < ActiveRecord::Migration
  def change
    add_column :annotations, :updated_by_id, :integer
  end
end
