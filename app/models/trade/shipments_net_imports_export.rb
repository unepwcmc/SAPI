# Implements "net imports" shipments export
class Trade::ShipmentsNetImportsExport < Trade::ShipmentsGrossExportsExport
  include Trade::ShipmentReportQueries

private

  # the query before pivoting
  def subquery_sql
    net_imports_query
  end

  def resource_name
    "net_imports"
  end

end
