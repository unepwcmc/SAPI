require Rails.root.join('lib/tasks/elibrary/importable.rb')

class Elibrary::DocumentDiscussionsImporter
  include Elibrary::Importable

  def initialize(file_name)
    @file_name = file_name
  end

  def table_name
    :elibrary_document_discussions_import
  end

  def columns_with_type
    [
      [ 'EventTypeName', 'TEXT' ],
      [ 'EventName', 'TEXT' ],
      [ 'EventDate', 'TEXT' ],
      [ 'DocumentTypeName', 'TEXT' ],
      [ 'DocumentID', 'INT' ],
      [ 'DocumentTitle', 'TEXT' ],
      [ 'DocumentFilePath', 'TEXT' ],
      [ 'DocumentFileName', 'TEXT' ],
      [ 'DocumentDate', 'TEXT' ],
      [ 'DiscussionID', 'INT' ],
      [ 'DocumentOrder', 'TEXT' ],
      [ 'DiscussionTitle', 'TEXT' ]
    ]
  end

  def run_preparatory_queries
    ApplicationRecord.connection.execute("UPDATE #{table_name} SET DocumentOrder = NULL WHERE DocumentOrder='NULL'")
  end

  def run_queries
    # insert missing discussions
    sql = <<-SQL.squish
      WITH missing_discussions AS (
        SELECT DISTINCT DiscussionTitle FROM #{table_name}
        EXCEPT
        SELECT name FROM document_tags WHERE type='DocumentTag::Discussion'
      )
      INSERT INTO document_tags (name, type, created_at, updated_at)
      SELECT DiscussionTitle, 'DocumentTag::Discussion', NOW(), NOW()
      FROM missing_discussions;
    SQL
    ApplicationRecord.connection.execute(sql)

    # update documents
    sql = <<-SQL.squish
      WITH rows_to_insert AS (
        #{rows_to_insert_sql}
      )
      UPDATE documents
      SET discussion_id = t.discussion_id, discussion_sort_index = t.DocumentOrder
      FROM rows_to_insert t
      WHERE documents.id = t.id;
    SQL
    ApplicationRecord.connection.execute(sql)
  end

  def all_rows_sql
    sql = <<-SQL.squish
      SELECT
        DocumentID,
        CAST(DocumentOrder AS INT) AS DocumentOrder,
        DiscussionTitle
      FROM #{table_name}
    SQL
  end

  def rows_to_insert_sql
    sql = <<-SQL.squish
      SELECT
      d.id AS id,
      DocumentOrder,
      dd.id AS discussion_id
      FROM (
        SELECT * FROM (
          #{all_rows_sql}
        ) all_rows_in_table_name
        EXCEPT
        SELECT
          d.elib_legacy_id,
          d.discussion_sort_index,
          dd.name
        FROM (
          #{all_rows_sql}
        ) nd
        JOIN documents d ON d.elib_legacy_id = nd.DocumentID
        JOIN document_tags dd ON dd.id = d.discussion_id
      ) rows_to_insert
      JOIN documents d ON d.elib_legacy_id = rows_to_insert.DocumentID
      JOIN document_tags dd ON UPPER(BTRIM(dd.name)) = UPPER(BTRIM(DiscussionTitle))
    SQL
  end

  def print_breakdown
    Rails.logger.debug { <<-EOT }
      #{Time.zone.now} There are #{Document.where.not(discussion_id: nil).count} documents
      in #{DocumentTag.where(type: 'DocumentTag::Discussion').count} discussions in total
    EOT
  end
end
