class AddObjectChangesTextColumnToVersions < ActiveRecord::Migration[4.2]
  def change
    add_column :versions, :object_changes, :text
  end
end
