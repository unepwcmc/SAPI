class ChangeDocumentTagNameToText < ActiveRecord::Migration[4.2]
  def up
    change_column :document_tags, :name, :text, null: false
  end

  def down
    change_column :document_tags, :name, :string
  end
end
