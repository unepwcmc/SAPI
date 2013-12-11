# Implements "net imports" shipments export
class Trade::ShipmentsNetImportsExport < Trade::ShipmentsGrossExportsExport

private

  def resource_name
    "net_imports"
  end

  def table_name
    "trade_shipments_net_imports_view"
  end

end
