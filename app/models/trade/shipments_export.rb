require 'psql_command'
# Implements "raw" shipments export
class Trade::ShipmentsExport < Species::CsvCopyExport
  include Trade::ShipmentReportQueries
  PUBLIC_CSV_LIMIT = 1000000
  PUBLIC_WEB_LIMIT = 50000
  include ActiveModel::SerializerSupport
  delegate :report_type, :to => :"@search"
  delegate :page, :to => :"@search"
  delegate :per_page, :to => :"@search"

  def initialize(filters)
    @search = Trade::Filter.new(filters)
    @filters = @search.options.merge(:csv_separator => filters['csv_separator'])
    initialize_csv_separator(filters[:csv_separator])
    initialize_file_name
  end

  def export
    unless File.file?(@file_name)
      to_csv
    end
    unless File.file?(@file_name)
      Rails.logger.error("Unable to generate output")
      return false
    end
    ctime = File.ctime(@file_name).strftime('%Y-%m-%d %H:%M')
    @public_file_name = "#{resource_name}_#{ctime}_#{@csv_separator}_separated.csv"
    [
      @file_name,
      { :filename => public_file_name, :type => 'text/csv' }
    ]
  end

  def total_cnt
    basic_query(:limit => false).count
  end

  def query
    ActiveRecord::Base.connection.execute(query_sql(:limit => true))
  end

  def csv_column_headers
    report_columns.map do |column, properties|
      I18n.t "csv.#{column}"
    end
  end

  def get_resource_name
    resource_name
  end

  private

  def basic_query(options)
    options[:limit] ? @search.query_with_limit : @search.query
  end

  def query_sql(options)
    headers = csv_column_headers
    select_columns = sql_columns.each_with_index.map do |c, i|
      "#{c} AS \"#{headers[i]}\""
    end
    "SELECT #{select_columns.join(', ')} FROM (#{raw_query(options)}) subquery"
  end

  def internal?
    @filters[:internal]
  end

  def resource_name
    "shipments"
  end

  def table_name
    "trade_shipments_view"
  end

  def copy_stmt
    # escape quotes around attributes for psql
    sql = <<-PSQL
      \\COPY (#{query_sql(:limit => !internal?).gsub(/"/, "\\\"")})
      TO ?
      WITH DELIMITER '#{@csv_separator_char}'
      ENCODING 'latin1'
      CSV HEADER;
    PSQL
    ActiveRecord::Base.send(:sanitize_sql_array, [sql, @file_name])
  end

  def to_csv
    PsqlCommand.new(copy_stmt).execute
  end

  def available_columns
    {
      :id => { :internal => true },
      :year => {},
      :appendix => {},
      :taxon => {},
      :taxon_concept_id => { :internal => true },
      :class_name => { :internal => true },
      :order_name => { :internal => true },
      :family_name => { :internal => true },
      :genus_name => { :internal => true },
      :reported_taxon => { :internal => true },
      :reported_taxon_concept_id => { :internal => true },
      :term => { :en => :term_name_en, :es => :term_name_es, :fr => :term_name_fr },
      :quantity => {},
      :unit => { :en => :unit_name_en, :es => :unit_name_es, :fr => :unit_name_fr },
      :importer => {},
      :exporter => {},
      :country_of_origin => {},
      :purpose => {},
      :source => {},
      :reporter_type => { :internal => true },
      :import_permit_number => { :internal => true },
      :export_permit_number => { :internal => true },
      :origin_permit_number => { :internal => true },
      :legacy_shipment_number => { :internal => true },
      :created_by => { :internal => true },
      :updated_by => { :internal => true }
    }
  end

  def report_columns
    # reject internal columns when producing a public report
    available_columns.delete_if do |column, properties|
      !internal? && properties[:internal] == true
    end
  end

  def sql_columns
    report_columns.map { |column, properties| properties[I18n.locale] || column }
  end

end
