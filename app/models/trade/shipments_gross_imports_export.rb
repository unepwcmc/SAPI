# Implements "gross imports" shipments export
class Trade::ShipmentsGrossImportsExport < Trade::ShipmentsGrossExportsExport
  include Trade::ShipmentReportQueries

  def resource_name
    "gross_imports"
  end

private

  # the query before pivoting
  def subquery_sql
    gross_imports_query
  end

end
