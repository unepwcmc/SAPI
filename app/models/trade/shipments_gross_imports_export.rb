# Implements "gross imports" shipments export
class Trade::ShipmentsGrossImportsExport < Trade::ShipmentsGrossExportsExport

private

  def resource_name
    "gross_imports"
  end

  def table_name
    "trade_shipments_gross_imports_view"
  end

end
