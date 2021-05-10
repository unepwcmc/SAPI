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
    general_subtype_column = <<-SQL
      case
        when general_subtype is TRUE
          then 'Whole animals/plants'
        else 'Parts and derivatives'
      end
    SQL

    [
      :id,
      :manual_id,
      :title,
      :volume,
      :date,
      :document_type,
      general_subtype_column,
      :language,
      :primary_document_id,
      :taxon_names,
      :geo_entity_names,
      "to_char(created_at, 'DD/MM/YYYY')",
      "to_char(updated_at, 'DD/MM/YYYY')",
      :created_by_id,
      :created_by,
      :updated_by_id,
      :updated_by
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
      'Identification type',
      'Language',
      'Primary ID',
      'Taxon names',
      'Country names',
      'Created at',
      'Updated at',
      'Created by id',
      'Created by',
      'Updated by id',
      'Updated by'
    ]
  end

end
