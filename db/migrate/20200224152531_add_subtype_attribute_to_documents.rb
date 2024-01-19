class AddSubtypeAttributeToDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :general_subtype, :boolean
  end
end
