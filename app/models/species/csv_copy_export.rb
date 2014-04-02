require 'psql_command'
class Species::CsvCopyExport < Species::CsvExport

private
  def query_sql
    headers = csv_column_headers
    select_columns = sql_columns.each_with_index.map do |c, i|
      "#{c} AS \"#{headers[i]}\""
    end
    query.select(select_columns).to_sql
  end

  def copy_stmt
    # escape quotes around attributes for psql
    sql =<<-PSQL
      \\COPY (#{query_sql.gsub(/"/,"\\\"")})
      TO ?
      WITH DELIMITER ','
      ENCODING 'utf8'
      CSV HEADER;
    PSQL
    ActiveRecord::Base.send(:sanitize_sql_array, [sql, @file_name])
  end

  def to_csv
    PsqlCommand.new(copy_stmt).execute
  end

end