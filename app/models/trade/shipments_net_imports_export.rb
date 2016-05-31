# Implements "net imports" shipments export
class Trade::ShipmentsNetImportsExport < Trade::ShipmentsGrossExportsExport
  include Trade::ShipmentReportQueries

  private

  # the query before pivoting
  def subquery_sql(options)
    net_imports_query(options)
  end

  def resource_name
    "net_imports"
  end

end
