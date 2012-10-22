class RenameColumnTypeToDocType < ActiveRecord::Migration
  def up
    rename_column :downloads, :type, :doc_type
  end

  def down
    rename_column :downloads, :doc_type, :type
  end
end
