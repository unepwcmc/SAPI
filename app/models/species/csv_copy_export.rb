require 'psql_command'
class Species::CsvCopyExport < Species::CsvExport

private
  def select_columns
    headers = csv_column_headers
    select_columns = sql_columns.each_with_index.map do |c, i|
      "#{c} AS \"#{headers[i]}\""
    end
  end

  def query_sql
    query.select(select_columns).to_sql
  end

  def copy_stmt
    # escape quotes around attributes for psql
    sql =<<-PSQL
      \\COPY (#{query_sql.gsub(/"/,"\\\"")})
      TO :file_name
      WITH DELIMITER ','
      ENCODING 'utf8'
      CSV HEADER;
    PSQL
    ActiveRecord::Base.send(:sanitize_sql_array, [sql, {:file_name => @file_name}])
  end

  def to_csv
    PsqlCommand.new(copy_stmt).execute
  end

end
