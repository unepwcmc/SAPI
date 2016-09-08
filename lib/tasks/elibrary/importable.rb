module Elibrary
  module Importable

    def run
      drop_table_if_exists(table_name)
      create_table_from_column_array(
        table_name, columns_with_type.map { |ct| ct.join(' ') }
      )
      copy_from_csv(
        @file_name, table_name, columns_with_type.map { |ct| ct.first }
      )
      run_preparatory_queries
      print_pre_import_stats
      run_queries
      print_post_import_stats
    end

    def drop_table_if_exists(table_name)
      ActiveRecord::Base.connection.execute "DROP TABLE IF EXISTS #{table_name} CASCADE"
      puts "Table removed"
    end

    def create_table_from_column_array(table_name, db_columns_with_type)
      drop_table_if_exists(table_name)
      ActiveRecord::Base.connection.execute "CREATE TABLE #{table_name} (#{db_columns_with_type.join(', ')})"
      puts "Table created"
    end

    def copy_from_csv(path_to_file, table_name, db_columns)
      require 'psql_command'
      puts "Copying data from #{path_to_file} into #{table_name}"
      cmd = <<-PSQL
    SET DateStyle = \"ISO,DMY\";
    \\COPY #{table_name} (#{db_columns.join(', ')})
    FROM '#{Rails.root + path_to_file}'
    WITH DELIMITER ','
    ENCODING 'utf-8'
    CSV HEADER
    PSQL
      PsqlCommand.new(cmd).execute
      puts "Data copied to tmp table"
    end

    def print_query_counts
      queries = { 'rows_in_import_file' => "SELECT COUNT(*) FROM #{table_name}" }
      queries['rows_to_insert'] = "SELECT COUNT(*) FROM (#{rows_to_insert_sql}) t"
      queries.each do |q_name, q|
        res = ActiveRecord::Base.connection.execute(q)
        puts "#{res[0]['count']} #{q_name.humanize}"
      end
    end

    def print_breakdown; end

    def print_pre_import_stats
      print_breakdown
      print_query_counts
    end

    def print_post_import_stats
      print_breakdown
    end
  end
end
