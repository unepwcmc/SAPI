require Rails.root.join('lib/tasks/elibrary/helpers.rb')
namespace 'elibrary:documents' do

  def import_table; :elibrary_documents_import; end

  def all_rows_in_import_table_sql
    sql = <<-SQL
      SELECT
        EventID,
        CASE WHEN DocumentOrder = 'NULL' THEN NULL ELSE DocumentOrder END AS DocumentOrder,
        BTRIM(splus_document_type) AS splus_document_type,
        DocumentID,
        BTRIM(DocumentTitle) AS DocumentTitle,
        CAST(DocumentDate AS DATE) AS DocumentDate,
        BTRIM(DocumentFileName) AS DocumentFileName,
        REGEXP_REPLACE(BTRIM(DocumentFilePath), BTRIM(DocumentFileName) || '$','') AS DocumentFilePath,
        CASE WHEN DocumentIsPubliclyAccessible = 1 THEN TRUE ELSE FALSE END AS DocumentIsPubliclyAccessible,
        CASE WHEN LanguageName = 'Unspecified' THEN NULL ELSE LanguageName END AS LanguageName,
        MasterDocumentID
      FROM #{import_table}
    SQL
  end

  def rows_to_insert_sql
    sql = <<-SQL
      SELECT * FROM (
        #{all_rows_in_import_table_sql}
      ) all_rows_in_import_table
      EXCEPT
      SELECT
        e.elib_legacy_id,
        d.sort_index,
        d.type,
        d.elib_legacy_id,
        d.title,
        d.date,
        d.elib_legacy_file_name,
        d.elib_legacy_file_path,
        d.is_public,
        lng.name_en,
        d.primary_language_document_id,
        primary_d.elib_legacy_id
      FROM (
        #{all_rows_in_import_table_sql}
      ) nd
      JOIN documents d ON d.elib_legacy_id = nd.DocumentID
      LEFT JOIN events e ON e.id = d.event_id
      LEFT JOIN languages lng ON lng.id = document.language_id
      LEFT JOIN documents primary_d ON primary_d.elib_legacy_id = nd.MasterDocumentID
    SQL
  end

  def print_documents_breakdown
    puts "#{Time.now} There are #{Document.count} documents in total"
    Document.group(:type).order(:type).count.each do |type, count|
      puts "\t #{type} #{count}"
    end
  end

  desc 'Import documents from csv file'
  task :import => :environment do |task_name|
    check_file_provided(task_name)
    drop_table_if_exists(import_table)
    columns_with_type = [
      ['EventTypeID', 'INT'],
      ['EventTypeName', 'TEXT'],
      ['splus_event_type', 'TEXT'],
      ['EventID', 'INT'],
      ['EventName', 'TEXT'],
      ['EventDate', 'TEXT'],
      ['MeetingType', 'TEXT'],
      ['EventDocumentReference', 'TEXT'],
      ['DocumentOrder', 'TEXT'],
      ['DocumentTypeID', 'INT'],
      ['DocumentTypeName', 'TEXT'],
      ['splus_document_type', 'TEXT'],
      ['DocumentID', 'INT'],
      ['DocumentTitle', 'TEXT'],
      ['supertitle', 'TEXT'],
      ['subtitle', 'TEXT'],
      ['DocumentDate', 'TEXT'],
      ['DocumentFileName', 'TEXT'],
      ['DocumentFilePath', 'TEXT'],
      ['DocumentIsPubliclyAccessible', 'TEXT'],
      ['DateCreated', 'TEXT'],
      ['DateModified', 'TEXT'],
      ['LanguageName', 'TEXT'],
      ['DocumentIsTranslationIntoEnglish', 'TEXT'],
      ['MasterDocumentID', 'INT']
    ]
    create_table_from_column_array(
      import_table, columns_with_type.map{ |ct| ct.join(' ') }
    )
    copy_from_csv(
      ENV['FILE'], import_table, columns_with_type.map{ |ct| ct.first }
    )

    print_documents_breakdown
    print_pre_import_stats

    sql = <<-SQL
      WITH rows_to_insert AS (
        #{rows_to_insert_sql}
      ), rows_to_insert_resolved AS (
        SELECT
        events.id AS event_id,
        DocumentOrder,
        splus_document_type,
        DocumentID,
        DocumentTitle,
        DocumentDate,
        DocumentFileName,
        DocumentFilePath,
        DocumentIsPubliclyAccessible,
        lng.id AS language_id
        FROM rows_to_insert
        JOIN events e ON e.elib_legacy_id = rows_to_insert.EventID
        JOIN languages lng ON UPPER(lng.name_en) = UPPER(rows_to_insert.LanguageName)
      ), inserted_rows AS (
        INSERT INTO "documents" (
          event_id,
          sort_index,
          type,
          elib_legacy_id,
          title,
          date,
          elib_legacy_file_name,
          elib_legacy_file_path,
          is_public,
          language_id
        )
        SELECT
          rows_to_insert_resolved.*,
          NOW(),
          NOW()
        FROM rows_to_insert_resolved
      ), rows_to_insert_with_master_document_id AS (
        SELECT documents.id, master_documents.id AS primary_language_document_id
        FROM rows_to_insert
        JOIN documents ON documents.elib_legacy_id = rows_to_insert.DocumentID
        JOIN documents master_documents ON master_documents.elib_legacy_id = rows_to_insert.MasterDocumentID
      )
      -- now resolve the self-reference to master document
      UPDATE documents
      SET primary_language_document_id = rows_to_insert_with_master_document_id.primary_language_document_id
      FROM rows_to_insert_with_master_document_id
      WHERE rows_to_insert_with_master_document_id.id = documents.id
    SQL
    ActiveRecord::Base.connection.execute(sql)

    print_documents_breakdown
  end
end
