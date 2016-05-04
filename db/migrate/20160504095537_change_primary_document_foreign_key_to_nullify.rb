class ChangePrimaryDocumentForeignKeyToNullify < ActiveRecord::Migration
  def up
    remove_foreign_key :documents,
      name: 'documents_primary_language_document_id_fk'
    add_foreign_key :documents, :documents,
      name: 'documents_primary_language_document_id_fk',
      column: 'primary_language_document_id',
      dependent: :nullify
  end

  def down
    remove_foreign_key :documents,
      name: 'documents_primary_language_document_id_fk'
    add_foreign_key :documents, :documents,
      name: 'documents_primary_language_document_id_fk',
      column: 'primary_language_document_id'
  end
end
