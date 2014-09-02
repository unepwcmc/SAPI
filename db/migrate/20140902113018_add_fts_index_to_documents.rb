class AddFtsIndexToDocuments < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE INDEX index_documents_on_title_to_ts_vector
      ON documents USING GIN(TO_TSVECTOR('simple', COALESCE(documents.title::text, '')))
    SQL
  end
end
