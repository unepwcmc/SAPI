class AddTimestampsToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :created_at, :datetime
    add_column :documents, :updated_at, :datetime
    execute 'UPDATE documents SET created_at = NOW() WHERE created_at IS NULL'
    execute 'UPDATE documents SET updated_at = NOW() WHERE updated_at IS NULL'
    change_column :documents, :created_at, :datetime, :null => false
    change_column :documents, :updated_at, :datetime, :null => false
  end
end
