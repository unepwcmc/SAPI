class AddTypeToDocumentTag < ActiveRecord::Migration
  def change
    add_column :document_tags, :type, :string
  end
end
