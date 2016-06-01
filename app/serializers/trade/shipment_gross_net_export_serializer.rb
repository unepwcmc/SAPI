class Trade::ShipmentGrossNetExportSerializer < Trade::ShipmentComptabExportSerializer
  attributes :rows, :column_headers
  def rows
    object.query
  end

  def column_headers
    object.full_csv_column_headers
  end
end
