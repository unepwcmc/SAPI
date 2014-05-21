class AddCreatedByIdToAnnotations < ActiveRecord::Migration
  def change
    add_column :annotations, :created_by_id, :integer
  end
end
