require 'psql_command'
module CsvExportable

  def export_to_csv(options)
    PsqlCommand.new(copy_stmt(options)).execute
  end

  private

  def copy_stmt(options)
    basic_query = query_sql(options[:query], options[:csv_columns])
    # escape quotes around attributes for psql
    sql = <<-PSQL
      \\COPY (#{basic_query.gsub(/"/, "\\\"")})
      TO :file_name
      WITH DELIMITER :delimiter
      ENCODING :encoding
      CSV HEADER;
    PSQL
    ActiveRecord::Base.send(
      :sanitize_sql_array, [sql, {
        :delimiter => options[:delimiter] || ',',
        :encoding => options[:encoding] || 'UTF8',
        :file_name => options[:file_path]
      }]
    )
  end

  def query_sql(query, csv_columns)
    sql_columns = query.select_values
    query.except(:select).select(select_columns(sql_columns, csv_columns)).to_sql
  end

  def select_columns(sql_columns, csv_columns)
    sql_columns.each_with_index.map do |c, i|
      "#{c} AS \"#{csv_columns[i]}\""
    end
  end

end
