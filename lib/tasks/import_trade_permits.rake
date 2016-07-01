namespace :import do
  desc "Import trade permits from csv file (usage: rake import:trade_permits[path/to/file])"
  task :trade_permits, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|

    TMP_TABLE = "permits_import"
    permits_import_to_index = { "permits_import" => ["permit_number", "shipment_number", "permit_reporter_type"] }
    trade_shipments_indexed = { "trade_shipments" => ["export_permits_ids", "import_permits_ids", "origin_permits_ids"] }
    trade_shipments_to_index = { "trade_shipments" => ["legacy_shipment_number"] }

    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      drop_indices(permits_import_to_index)
      drop_indices(trade_shipments_to_index)

      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      create_indices(permits_import_to_index, "btree")

      populate_trade_permits

      drop_indices(trade_shipments_indexed)
      create_indices(trade_shipments_to_index, "btree")

      insert_into_trade_shipments

      create_indices(trade_shipments_indexed, "GIN")
      drop_indices(trade_shipments_to_index)
      drop_indices(permits_import_to_index)
    end
  end
end

def execute_query(sql)
  ActiveRecord::Base.connection.execute(sql)
end

def drop_indices(index)
  index.each do |table, columns|
    columns.each do |column|
      sql = <<-SQL
      DROP INDEX IF EXISTS index_#{table}_on_#{column};
      SQL
      puts "Dropping index #{column} on #{table} #{Time.now.strftime("%d/%m/%Y %H:%M")}"
      execute_query(sql)
    end
  end
end

def create_indices(table_columns, method)
  table_columns.each do |table, columns|
    columns.each do |column|
      sql = <<-SQL
      CREATE INDEX index_#{table}_on_#{column}
      ON #{table}
      USING #{method}
      (#{column});
      SQL
      puts "Creating index for #{column} #{Time.now.strftime("%d/%m/%Y %H:%M")}"
      execute_query(sql)
    end
  end
end

def populate_trade_permits
  sql = <<-SQL
  INSERT INTO trade_permits (number, created_At, updated_at)
  SELECT DISTINCT permit_number,
         now()::date AS created_at,
         now()::date AS updated_at
  FROM permits_import;
  SQL
  puts "Inserting into trade_permits #{Time.now.strftime("%d/%m/%Y %H:%M")}"
  execute_query(sql)
end

def insert_into_trade_shipments
  permits_entity = { "import" => "I", "export" => 'E', "origin" => 'O' }
  permits_entity.each do |k, v|
    sql = <<-SQL
      WITH grouped_permits AS (
        SELECT array_agg(id) AS ids,
          string_agg(number, ';') AS permit_number,
          permits_import.shipment_number AS shipment_number
        FROM trade_permits
        INNER JOIN permits_import ON permits_import.permit_reporter_type = '#{v}'
        AND permits_import.permit_number = trade_permits.number
        GROUP BY permits_import.shipment_number
      )
      UPDATE trade_shipments
      SET #{k}_permits_ids = grouped_permits.ids, #{k}_permit_number = grouped_permits.permit_number
      FROM grouped_permits
      WHERE trade_shipments.legacy_shipment_number = grouped_permits.shipment_number
    SQL
    puts "Inserting #{k} permits into trade_shipments #{Time.now.strftime("%d/%m/%Y %H:%M")}"
    execute_query(sql)
  end
end
