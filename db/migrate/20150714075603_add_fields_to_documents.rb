class AddFieldsToDocuments < ActiveRecord::Migration
  def change
    execute 'DROP VIEW documents_view'
    rename_column :documents, :legacy_id, :elib_legacy_id
    add_column :documents, :sort_index, :integer
    add_column :documents, :primary_language_document_id, :integer
    add_column :documents, :elib_legacy_file_name, :text
    add_foreign_key :documents, :documents, name: 'documents_primary_language_document_id_fk',
      column: 'primary_language_document_id'
    execute "CREATE VIEW documents_view AS #{view_sql('20141223141125', 'documents_view')}"
  end
end
