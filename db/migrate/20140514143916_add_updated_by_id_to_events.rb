class AddUpdatedByIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :updated_by_id, :integer
  end
end
