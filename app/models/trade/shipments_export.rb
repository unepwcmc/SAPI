require 'psql_command'
# Implements "raw" shipments export
class Trade::ShipmentsExport < Species::CsvExport

  def initialize(filters = {})
    @filters = filters || {}
    @search = Trade::Filter.new(@filters)
  end

  def query
    headers = csv_column_headers
    select_columns = sql_columns.each_with_index.map do |c, i|
      "#{c} AS \\\"#{headers[i]}\\\""
    end
    puts select_columns.inspect
    @search.query.select(select_columns)

    #@search.query.select(sql_columns)
  end

private

  def resource_name
    "shipments"
  end

  def table_name
    "trade_shipments_view"
  end

  def copy_stmt(query)
    sql = <<-PSQL
      \\COPY (#{query.to_sql})
      TO ?
      WITH DELIMITER ','
      ENCODING 'utf-8'
      CSV HEADER;
    PSQL
    ActiveRecord::Base.send(:sanitize_sql_array, [sql, @file_name])
  end

  def to_csv
    PsqlCommand.new(copy_stmt(query)).execute
  end

  def sql_columns
    [
      :id,
      :year,
      :appendix,
      :taxon,
      :reported_taxon,
      :importer,
      :exporter,
      :reporter_type,
      :country_of_origin,
      :quantity,
      :unit,
      :term,
      :purpose,
      :source,
      :import_permit_number,
      :export_permit_number,
      :country_of_origin_permit_number
    ]
  end

  def csv_column_headers
    sql_columns.map{ |c| c.to_s.humanize }
  end

end
