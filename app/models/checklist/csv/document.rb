require 'csv'
module Checklist::Csv::Document

  def ext
    'csv'
  end

  def document
    CSV.open(@download_path, "wb") do |csv|
      yield csv
    end

    @download_path
  end

  def column_headers
    (taxon_concepts_csv_columns + listing_changes_csv_columns).map do |c|
      column_export_name(c)
    end
  end

  def column_export_name(col)
    Checklist::ColumnDisplayNameMapping.column_display_name_for(col)
  end

end
