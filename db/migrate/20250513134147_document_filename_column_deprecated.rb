class DocumentFilenameColumnDeprecated < ActiveRecord::Migration[7.1]
  def change
    change_column_null :documents, :filename, true
  end
end
