class AddUpdatedByIdToCommonNames < ActiveRecord::Migration
  def change
    add_column :common_names, :updated_by_id, :integer
  end
end
