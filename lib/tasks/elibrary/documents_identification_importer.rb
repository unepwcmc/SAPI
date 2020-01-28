require Rails.root.join('lib/tasks/elibrary/importable.rb')

class Elibrary::DocumentsIdentificationImporter
  include Elibrary::Importable

  def initialize(file_name)
    @file_name = file_name
    @file_name =~ /documents_(.+)\.csv$/
    @document_group = $1
  end

  def table_name
    :"elibrary_documents_#{@document_group}_import"
  end

  def columns_with_type
    [
      ['DocumentDate', 'TEXT'],
      ['Manual_ID', 'TEXT'],
      ['DocumentTitle', 'TEXT'],
      ['LanguageName', 'TEXT'],
      ['Master_Document_ID', 'TEXT'],
      ['Type', 'TEXT'],
      ['DocumentFileName', 'TEXT'],
      ['Volume', 'TEXT']
    ]
  end

  def run_preparatory_queries
  #   ActiveRecord::Base.connection.execute("DELETE FROM #{table_name} WHERE Type LIKE 'CITES%'")
  #   ActiveRecord::Base.connection.execute("DELETE FROM #{table_name} WHERE Type LIKE 'Virtual%'")
  #   ActiveRecord::Base.connection.execute("UPDATE #{table_name} SET DocumentTitle = NULL WHERE DocumentTitle='NULL'")
  #   ActiveRecord::Base.connection.execute("UPDATE #{table_name} SET DocumentDate = NULL WHERE DocumentDate='NULL'")
  #   ActiveRecord::Base.connection.execute("UPDATE #{table_name} SET DocumentFileName = NULL WHERE DocumentFileName='NULL'")
  end

  def run_queries
    # insert master documents
    sql = <<-SQL
      WITH rows_to_insert AS (
        #{rows_to_insert_sql}
      ), rows_to_insert_resolved AS (
        SELECT
        Type,
        Manual_ID,
        DocumentTitle,
        DocumentDate,
        DocumentFileName AS filename,
        DocumentFileName,
        DocumentIsPubliclyAccessible,
        lng.id AS language_id,
        Volume
        FROM rows_to_insert
        LEFT JOIN languages lng ON UPPER(lng.iso_code1) = UPPER(rows_to_insert.LanguageName)
      )

      INSERT INTO "documents" (
        type,
        manual_id,
        title,
        date,
        filename,
        elib_legacy_file_name,
        is_public,
        language_id,
        volume,
        created_at,
        updated_at
      )
      SELECT
        rows_to_insert_resolved.*,
        NOW(),
        NOW()
      FROM rows_to_insert_resolved
    SQL
    ActiveRecord::Base.connection.execute(sql)

    # now insert the documents to be linked with the master document
    sql = <<-SQL
      WITH rows_with_master_document_id AS (
        SELECT
        rows_to_insert.Type,
        rows_to_insert.Manual_ID,
        DocumentTitle,
        DocumentDate,
        DocumentFileName AS filename,
        DocumentFileName,
        DocumentIsPubliclyAccessible,
        lng.id AS language_id,
        rows_to_insert.Volume,
        master_documents.id AS primary_language_document_id
        FROM (
          #{all_rows_sql}
          WHERE Master_Document_ID IS NOT NULL
          ) rows_to_insert
        JOIN documents master_documents ON master_documents.manual_id = rows_to_insert.Master_Document_ID
        LEFT JOIN languages lng ON UPPER(lng.iso_code1) = UPPER(rows_to_insert.LanguageName)
          AND rows_to_insert.DocumentDate = master_documents.date
          AND rows_to_insert.Type = master_documents.type
          AND master_documents.language_id IS NOT NULL
      )

      INSERT INTO "documents" (
        type,
        manual_id,
        title,
        date,
        filename,
        elib_legacy_file_name,
        is_public,
        language_id,
        volume,
        primary_language_document_id,
        created_at,
        updated_at
      )
      SELECT
        rows_with_master_document_id.*,
        NOW(),
        NOW()
      FROM rows_with_master_document_id
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  def all_rows_sql
    byebug
    sql = <<-SQL
      SELECT
        CASE WHEN BTRIM(t.Type) LIKE '%Manual%' THEN 'Document::IdManual'
             WHEN BTRIM(t.Type) LIKE '%Virtual%' THEN 'Document::VirtualCollege'
        END AS Type,
        Manual_ID,
        BTRIM(DocumentTitle) AS DocumentTitle,
        TO_DATE(DocumentDate::TEXT, 'YYYY-MM-DD') AS DocumentDate,
        BTRIM(DocumentFileName) AS DocumentFileName,
        TRUE AS DocumentIsPubliclyAccessible,
        LanguageName,
        Master_Document_ID,
        Volume
      FROM #{table_name} t
    SQL
  end

  def rows_to_insert_sql
    byebug
    sql = <<-SQL
      SELECT * FROM (
        #{all_rows_sql}
      ) all_rows_in_table_name
      WHERE DocumentDate IS NOT NULL
        AND Type IS NOT NULL
        AND DocumentFileName IS NOT NULL
        AND DocumentTitle IS NOT NULL
        AND Master_Document_ID IS NULL
      EXCEPT
      SELECT
        d.type,
        d.manual_id,
        d.title,
        d.date,
        d.elib_legacy_file_name,
        d.is_public,
        lng.iso_code1,
        NULL,
        d.volume
      FROM (
        #{all_rows_sql}
      ) nd
      JOIN documents d ON d.manual_id = nd.Manual_ID
      LEFT JOIN languages lng ON lng.id = d.language_id
    SQL
  end

  def print_breakdown
    puts "#{Time.now} There are #{Document.count} documents in total"
    Document.group(:type).order(:type).count.each do |type, count|
      puts "\t #{type} #{count}"
    end
  end

end
