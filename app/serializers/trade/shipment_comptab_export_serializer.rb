class Trade::ShipmentComptabExportSerializer < ActiveModel::Serializer
  attributes :rows, :column_headers
  def rows
    object.query
  end
  def column_headers
    object.csv_column_headers
  end
end
