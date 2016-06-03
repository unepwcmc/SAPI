class ChangeDocumentTagNameToText < ActiveRecord::Migration
  def up
    change_column :document_tags, :name, :text, null: false
  end

  def down
    change_column :document_tags, :name, :string
  end
end
