class UpdateDocumentLanguageVersionTypeForChecklistDocsSearch < ActiveRecord::Migration
  def up
    execute "DROP TYPE document_language_version"
    execute <<-SQL
      CREATE TYPE document_language_version AS (
        id INT,
        title TEXT,
        LANGUAGE TEXT,
        locale_document TEXT
      )
    SQL
  end

  def down
    execute "DROP TYPE document_language_version"
    execute <<-SQL
      CREATE TYPE document_language_version AS (
        id INT,
        title TEXT,
        LANGUAGE TEXT
      )
    SQL
  end
end
