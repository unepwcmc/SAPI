class Trade::SandboxTemplate < ActiveRecord::Base
	self.table_name = :trade_sandbox_template

  private
  def self.create_stmt(target_table_name)
    sql = <<-SQL
      CREATE TABLE #{target_table_name} () INHERITS (#{table_name})
    SQL
  end

  def self.copy_stmt(target_table_name, csv_file_path)
    sql = <<-SQL
      COPY #{target_table_name} (#{column_names.join(', ')})
      FROM ?
        WITH DELIMITER ','
        ENCODING 'utf-8'
        CSV HEADER
    SQL
    sanitize_sql_array([
      sql, csv_file_path
    ])
  end
end
