# Implements "gross exports" shipments export
class Trade::ShipmentsGrossExportsExport < Trade::ShipmentsComptabExport

  def query
    headers = csv_column_headers
    select_columns = sql_columns.each_with_index.map do |c, i|
      "#{c} AS \"#{headers[i]}\""
    end + years_columns
    Trade::Shipment.select(select_columns).from("(#{crosstab_query}) ct_subquery")
  end

private

  def resource_name
    "gross_exports"
  end

  def outer_report_columns
    # reject subquery columns
    puts report_columns.inspect
    puts internal?
    report_columns.delete_if { |column, properties| properties[:subquery] == true }
  end

  def sql_columns
    # locale will already be resolved
    outer_report_columns.map{ |column, properties| column }
  end

  def csv_column_headers
    outer_report_columns.map do |column, properties|
      I18n.t "csv.#{column}"
    end
  end

  def table_name
    "trade_shipments_gross_exports_view"
  end

  def years
    (@filters[:time_range_start]..@filters[:time_range_end]).to_a
  end

  def years_columns
    years.map{ |y| "\"#{y}\"" }
  end

  def available_columns
    {
      :appendix => {},
      :taxon => {},
      :taxon_concept_id => {:internal => true},
      :term => {:en => :term_name_en, :es => :term_name_es, :fr => :term_name_fr},
      :unit => {:en => :unit_name_en, :es => :unit_name_es, :fr => :unit_name_fr},
      :country => {},
      :year => {:subquery => true},
      :gross_quantity => {:subquery => true}
    }
  end

  # extra columns returned by crosstab
  def crosstab_columns
    {
      :appendix => {:pg_type => 'TEXT'},
      :taxon_concept_id => {:pg_type => 'INT'},
      :taxon => {:pg_type => 'TEXT'},
      :term => {:pg_type => 'TEXT'},
      :unit  => {:pg_type => 'TEXT'},
      :country  => {:pg_type => 'TEXT'}
    }
  end

  # the query before pivoting
  def subquery
    @search.query.select(report_columns.keys)
  end

  # pivots the quantity by year
  def crosstab_query
    extra_crosstab_columns = crosstab_columns.keys
    extra_crosstab_columns &= report_columns.keys
    # the source query contains a viariable number of "extra" columns
    # ones needed in the output but not involved in pivoting
    source_sql = "SELECT ARRAY[taxon, term, unit, country],
      #{extra_crosstab_columns.join(', ')}, year, gross_quantity
      FROM (#{subquery.to_sql}) subquery
      ORDER BY 1, #{extra_crosstab_columns.length + 2}" #order by row_name and year
    source_sql = ActiveRecord::Base.send(:sanitize_sql_array, [source_sql, years])
    # the categories query returns values by which to pivot (years)
    categories_sql = 'SELECT * FROM UNNEST(ARRAY[?])'
    categories_sql = ActiveRecord::Base.send(:sanitize_sql_array, [categories_sql, years.map(&:to_i)])
    year_columns = years_columns.map{ |y| "#{y} numeric"}.join(', ')
    # a set returning query requires that output columns are specified
    <<-SQL
      SELECT * FROM CROSSTAB('#{source_sql}', '#{categories_sql}')
      AS ct(
        row_name TEXT[],
        #{extra_crosstab_columns.map{ |c| "#{c} #{crosstab_columns[c][:pg_type]}"}.join(', ')},
        #{year_columns}
      )
    SQL
  end

end
