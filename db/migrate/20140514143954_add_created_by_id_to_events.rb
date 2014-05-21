class AddCreatedByIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :created_by_id, :integer
  end
end
