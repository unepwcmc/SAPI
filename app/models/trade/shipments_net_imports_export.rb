# Implements "net imports" shipments export
class Trade::ShipmentsNetImportsExport < Trade::ShipmentsGrossExportsExport
  include Trade::ShipmentReportQueries

  def resource_name
    "net_imports"
  end

private

  # the query before pivoting
  def subquery_sql
    net_imports_query
  end

end
