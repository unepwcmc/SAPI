# Implements "net exports" shipments export
class Trade::ShipmentsNetExportsExport < Trade::ShipmentsGrossExportsExport
  include Trade::ShipmentReportQueries

  def resource_name
    "net_exports"
  end

private

  # the query before pivoting
  def subquery_sql
    net_exports_query
  end

end
