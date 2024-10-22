class AddFtsIndexToDocuments < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL.squish
      CREATE INDEX index_documents_on_title_to_ts_vector
      ON documents USING GIN(TO_TSVECTOR('simple', COALESCE(documents.title::text, '')))
    SQL
  end
end
