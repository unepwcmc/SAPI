# Implements "gross imports" shipments export
class Trade::ShipmentsGrossImportsExport < Trade::ShipmentsGrossExportsExport

private

  def table_name
    "trade_shipments_gross_imports_view"
  end

end
