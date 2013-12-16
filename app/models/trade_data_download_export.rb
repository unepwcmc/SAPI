require 'psql_command'
# Implements "raw" shipments export
class Trade::ShipmentsExport < Species::CsvExport
  include ActiveModel::SerializerSupport

  def initialize(filters)
    @filters = filters
    @search = Trade::Filter.new(@filters)
  end

  def export
    if !File.file?(file_name)
      to_csv
    end
    ctime = File.ctime(@file_name).strftime('%Y-%m-%d %H:%M')
    @public_file_name = "#{resource_name}_#{ctime}.csv"
    [
      @file_name,
      {:filename => public_file_name, :type => 'text/csv'}
    ]
  end

  def total_cnt
    query.count
  end

  def query
    headers = csv_column_headers
    select_columns = sql_columns.each_with_index.map do |c, i|
      "#{c} AS \"#{headers[i]}\""
    end
    @search.query.select(select_columns)
  end

  def csv_column_headers
    report_columns.map do |column, properties|
      I18n.t "csv.#{column}"
    end
  end

private

  def query_sql
    query.to_sql
  end

  def internal?
    @filters['internal'] == true
  end

  def resource_name
    "shipments"
  end

  def table_name
    "trade_shipments_view"
  end

  def copy_stmt(query)
    # escape quotes around attributes for psql
    sql = <<-PSQL
      \\COPY (#{query_sql.gsub(/"/,"\\\"")})
      TO ?
      WITH DELIMITER ','
      ENCODING 'latin1'
      CSV HEADER;
    PSQL
    ActiveRecord::Base.send(:sanitize_sql_array, [sql, @file_name])
  end

  def to_csv
    PsqlCommand.new(copy_stmt(query)).execute
  end

  def available_columns
    {
      :id => {},
      :year => {},
      :appendix => {},
      :taxon => {},
      :taxon_concept_id => {:internal => true},
      :reported_taxon => {:internal => true},
      :reported_taxon_concept_id => {:internal => true},
      :term => {:en => :term_name_en, :es => :term_name_es, :fr => :term_name_fr},
      :quantity => {},
      :unit => {:en => :unit_name_en, :es => :unit_name_es, :fr => :unit_name_fr},
      :importer => {},
      :exporter => {},
      :country_of_origin => {},
      :purpose => {},
      :source => {},
      :reporter_type => {:internal => true},
      :import_permit_number => {:internal => true},
      :export_permit_number => {:internal => true},
      :country_of_origin_permit_number => {:internal => true}
    }
  end

  def report_columns
    # reject internal columns when producing a public report
    available_columns.delete_if do |column, properties|
      !internal? && properties[:internal] == true
    end
  end

  def sql_columns
    report_columns.map{ |column, properties| properties[I18n.locale] || column }
  end

end
