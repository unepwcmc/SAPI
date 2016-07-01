# Implements "gross exports" shipments export
class Trade::ShipmentsGrossExportsExport < Trade::ShipmentsComptabExport
  include Trade::ShipmentReportQueries

  # for the serializer
  def full_csv_column_headers
    csv_column_headers + years
  end

  private

  def query_sql(options)
    headers = csv_column_headers
    select_columns = sql_columns.each_with_index.map do |c, i|
      "#{c} AS \"#{headers[i]}\""
    end + years_columns
    "SELECT #{select_columns.join(', ')} FROM (#{ct_subquery_sql(options)}) ct_subquery"
  end

  def resource_name
    "gross_exports"
  end

  def outer_report_columns
    # reject subquery columns
    report_columns.delete_if { |column, properties| properties[:subquery] == true }
  end

  def sql_columns
    outer_report_columns.map { |column, properties| properties[I18n.locale] || column }
  end

  def csv_column_headers
    outer_report_columns.map do |column, properties|
      I18n.t "csv.#{column}"
    end
  end

  def years
    (@filters[:time_range_start]..@filters[:time_range_end]).to_a
  end

  def years_columns
    years.map { |y| "\"#{y}\"" }
  end

  def available_columns
    {
      :appendix => {},
      :taxon => {},
      :taxon_concept_id => { :internal => true },
      :term => { :en => :term_name_en, :es => :term_name_es, :fr => :term_name_fr },
      :unit => { :en => :unit_name_en, :es => :unit_name_es, :fr => :unit_name_fr },
      :country => {},
      :year => { :subquery => true },
      :gross_quantity => { :subquery => true }
    }
  end

  # extra columns returned by crosstab
  def row_name_columns
    [:appendix, :taxon, :term, :unit, :country]
  end

  def crosstab_columns
    {
      :appendix => { :pg_type => 'TEXT' },
      :taxon_concept_id => { :pg_type => 'INT' },
      :taxon => { :pg_type => 'TEXT' },
      :term => { :pg_type => 'TEXT' },
      :unit => { :pg_type => 'TEXT' },
      :country => { :pg_type => 'TEXT' }
    }
  end

  def sql_row_name_columns
    (row_name_columns & report_columns.keys).map do |c|
      available_columns[c][I18n.locale] || c
    end
  end

  def report_crosstab_columns
    crosstab_columns.keys & report_columns.keys
  end

  def sql_crosstab_columns
    report_crosstab_columns.map { |c| available_columns[c][I18n.locale] || c }
  end

  # the query before pivoting
  def subquery_sql(options)
    gross_exports_query(options)
  end

  # pivots the quantity by year
  def ct_subquery_sql(options)
    # the source query contains a variable number of "extra" columns
    # ones needed in the output but not involved in pivoting
    source_sql = "SELECT ARRAY[#{sql_row_name_columns.join(', ')}],
      #{sql_crosstab_columns.join(', ')}, year, gross_quantity
      FROM (#{subquery_sql(options)}) subquery
      ORDER BY 1, #{sql_crosstab_columns.length + 2}" # order by row_name and year
    source_sql = ActiveRecord::Base.send(:sanitize_sql_array, [source_sql, years])
    source_sql = ActiveRecord::Base.connection.quote_string(source_sql)
    # the categories query returns values by which to pivot (years)
    categories_sql = 'SELECT * FROM UNNEST(ARRAY[?])'
    categories_sql = ActiveRecord::Base.send(:sanitize_sql_array, [categories_sql, years.map(&:to_i)])
    ct_columns = [
      'row_name TEXT[]',
      report_crosstab_columns.map.each_with_index { |c, i| "#{sql_crosstab_columns[i]} #{crosstab_columns[c][:pg_type]}" },
      years_columns.map { |y| "#{y} numeric" }
    ].flatten.join(', ')
    # a set returning query requires that output columns are specified
    <<-SQL
      SELECT * FROM CROSSTAB('#{source_sql}', '#{categories_sql}')
      AS ct(#{ct_columns})
    SQL
  end

end
