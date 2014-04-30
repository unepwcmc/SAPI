class Species::CsvCopyExport < Species::CsvExport
  include CsvExportable

  private

  def to_csv
    export_to_csv({
      :query => query,
      :csv_columns => csv_column_headers,
      :file_path => file_name
    })
  end

end
