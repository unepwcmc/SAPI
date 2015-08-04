class AddOriginalIdToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :original_id, :integer
    add_foreign_key(:documents, :documents, column: :original_id, dependent: :nullify)
  end
end
