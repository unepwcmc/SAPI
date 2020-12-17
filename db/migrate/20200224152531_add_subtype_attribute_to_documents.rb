class AddSubtypeAttributeToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :general_subtype, :boolean
  end
end
