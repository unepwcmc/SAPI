class AddOriginalIdToDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :original_id, :integer
    add_foreign_key(:documents, :documents, column: :original_id, dependent: :nullify)
  end
end
