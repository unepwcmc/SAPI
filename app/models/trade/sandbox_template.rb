class Trade::SandboxTemplate < ActiveRecord::Base
  self.table_name = :trade_sandbox_template

  COLUMNS_IN_CSV_ORDER = [
    "appendix", "species_name", "term_code", "quantity", "unit_code",
    "trading_partner", "country_of_origin", "import_permit", "export_permit",
    "origin_permit", "purpose_code", "source_code", "year"
  ]
  IMPORTER_COLUMNS = COLUMNS_IN_CSV_ORDER
  EXPORTER_COLUMNS = COLUMNS_IN_CSV_ORDER - ['import_permit']

  private
  def self.create_stmt(target_table_name)
    sql = <<-SQL
      CREATE TABLE #{target_table_name} () INHERITS (#{table_name})
    SQL
  end

  def self.drop_stmt(target_table_name)
    sql = <<-SQL
      DROP TABLE #{target_table_name}
    SQL
  end

  def self.copy_stmt(target_table_name, csv_file_path, columns_in_csv_order)
    sql = <<-PSQL
      \\COPY #{target_table_name} (#{columns_in_csv_order.join(', ')})
      FROM ?
      WITH DELIMITER ','
      ENCODING 'utf-8'
      CSV HEADER
    PSQL
    sanitize_sql_array([
                       sql, csv_file_path
    ])
  end
end
