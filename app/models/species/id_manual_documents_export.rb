class Species::IdManualDocumentsExport < Species::CsvCopyExport

  def query
    rel = Document.from("#{table_name} documents")
                  .where(document_type: ['Document::IdManual', 'Document::VirtualCollege'])
                  .order('volume, manual_id')
    rel.select(sql_columns)
  end

  private

  def resource_name
    'documents'
  end

  def table_name
    'api_documents_mview'
  end

  def sql_columns
    [
      :id,
      :manual_id,
      :title,
      :volume,
      :date,
      :document_type,
      :language,
      :primary_document_id,
      :taxon_names,
      "to_char(created_at, 'DD/MM/YYYY')",
      "to_char(updated_at, 'DD/MM/YYYY')"
    ]
  end

  def csv_column_headers
    [
      'ID',
      'Manual ID',
      'Title',
      'Volume num.',
      'Date',
      'Document type',
      'Language',
      'Primary ID',
      'Taxon names',
      'Created at',
      'Updated at'
    ]
  end

end
