class UpdateDocumentsViewForSearch < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS api_documents_view"
    execute <<-SQL
      CREATE TYPE document_language_version AS (
        id INT,
        title TEXT,
        LANGUAGE TEXT
      )
    SQL
    execute "CREATE VIEW api_documents_view AS #{view_sql('20150806092509', 'api_documents_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS api_documents_view"
    execute "DROP TYPE document_language_version"
    execute "CREATE VIEW api_documents_view AS #{view_sql('20150730153305', 'api_documents_view')}"
  end
end
