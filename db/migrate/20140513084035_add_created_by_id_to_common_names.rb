class AddCreatedByIdToCommonNames < ActiveRecord::Migration
  def change
    add_column :common_names, :created_by_id, :integer
  end
end
