# Implements "net exports" shipments export
class Trade::ShipmentsNetExportsExport < Trade::ShipmentsGrossExportsExport

private

  def resource_name
    "net_exports"
  end

  def table_name
    "trade_shipments_net_exports_view"
  end

end
