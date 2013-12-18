class Trade::ShipmentComptabExportSerializer < ActiveModel::Serializer
  attributes :rows, :column_headers, :table_title
  def rows
    object.query
  end
  def column_headers
    object.csv_column_headers
  end
  def table_title
    debugger
    I18n.t "csv.#{column}"
  end
end
