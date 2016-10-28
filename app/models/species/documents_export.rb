class Species::DocumentsExport < Species::CsvCopyExport

  def query
    rel = Document.from("#{table_name} documents").
      order('event_type, date_raw, title')
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
      :event_name,
      :event_type,
      :date,
      :title,
      :is_public,
      :document_type,
      :language,
      :primary_document_id,
      :proposal_number,
      :proposal_outcome,
      :review_phase,
      :taxon_names,
      :geo_entity_names,
      "to_char(created_at, 'DD/MM/YYYY')",
      :created_by,
      "to_char(updated_at, 'DD/MM/YYYY')",
      :updated_by
    ]
  end

  def csv_column_headers
    [
      'ID',
      'Event name',
      'Event type',
      'Date',
      'Title',
      'Is public',
      'Document type',
      'Language',
      'Primary ID',
      'Proposal number',
      'Proposal outcome',
      'Review phase',
      'Taxon names',
      'Geo entity names',
      'Created at',
      'Created by',
      'Updated at',
      'Updated by'
    ]
  end

end
