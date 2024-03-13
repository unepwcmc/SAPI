# Implements "gross imports" shipments export
class Trade::ShipmentsGrossImportsExport < Trade::ShipmentsGrossExportsExport
  include Trade::ShipmentReportQueries

  private

  # the query before pivoting
  def subquery_sql(options)
    gross_imports_query(options)
  end

  def resource_name
    "gross_imports"
  end

end
