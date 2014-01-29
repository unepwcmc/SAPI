namespace :import do
    desc "Import trade permits from csv file (usage: rake import:trade_permits[path/to/file])"
    task :trade_permits, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|

      TMP_TABLE = "permits_import"
      permits_import_to_index = {"permits_import" => ["permit_number", "shipment_number", "permit_reporter_type"]}
      trade_permits_to_index = {"trade_permits" => ["shipment_number", "legacy_reporter_type"]}
      trade_shipments_indexed = {"trade_shipments" => ["export_permits_ids", "import_permits_ids", "origin_permits_ids"]}
      trade_shipments_to_index = {"trade_shipments" => ["legacy_shipment_number"]}


      files = files_from_args(t, args)
      files.each do |file|
        drop_table(TMP_TABLE)
        create_table_from_csv_headers(file, TMP_TABLE)
        copy_data(file, TMP_TABLE)

        drop_indices(trade_permits_to_index)
        drop_indices(permits_import_to_index)
        drop_indices(trade_shipments_to_index)

        drop_table(TMP_TABLE)
        create_table_from_csv_headers(file, TMP_TABLE)
        copy_data(file, TMP_TABLE)

        add_shipment_number_tmp_column
        create_indices(permits_import_to_index, "btree")

        populate_trade_permits

        create_indices(trade_permits_to_index, "btree")
        drop_indices(trade_shipments_indexed)
        create_indices(trade_shipments_to_index, "btree")

        insert_into_trade_shipments

        create_indices(trade_shipments_indexed, "GIN")
        drop_indices(trade_shipments_to_index)
        drop_indices(permits_import_to_index)
        delete_shipment_number_tmp_column
      end
  end
end

def execute_query sql
 ActiveRecord::Base.connection.execute(sql)
end

def drop_indices index
  index.each do |table, columns|
    columns.each do |column|
      sql = <<-SQL
      DROP INDEX IF EXISTS index_#{table}_on_#{column};
      SQL
      puts "Dropping index #{column} on #{table}"
      execute_query(sql)
    end
  end
end

def create_indices table_columns, method
  table_columns.each do |table,columns|
    columns.each do |column|
      sql = <<-SQL
      CREATE INDEX index_#{table}_on_#{column}
      ON #{table}
      USING #{method}
      (#{column});
      SQL
      puts "Creating index for #{column}"
      execute_query(sql)
    end
  end
end

def add_shipment_number_tmp_column
  delete_shipment_number_tmp_column
  sql = <<-SQL
    ALTER TABlE trade_permits ADD COLUMN shipment_number int;
  SQL
  execute_query(sql)
end

def delete_shipment_number_tmp_column
  sql = <<-SQL
    ALTER TABlE trade_permits DROP COLUMN IF EXISTS shipment_number;
  SQL
  execute_query(sql)
end

def populate_trade_permits
  sql = <<-SQL
  INSERT INTO trade_permits (number, shipment_number, legacy_reporter_type, created_At, updated_at)
  SELECT permit_number,
         shipment_number,
         permit_reporter_type,
         now()::date AS created_at,
         now()::date AS updated_at
  FROM permits_import;
  SQL
  puts "Inserting into trade_permits"
  execute_query(sql)
end

def insert_into_trade_shipments
  permits_entity = {"import" => "I", "export" => 'E', "origin" => 'O'}
  permits_entity.each do |k,v|
    sql = <<-SQL
    UPDATE trade_shipments
    SET #{k}_permits_ids = a.ids, #{k}_permit_number = permit_number
    FROM (SELECT array_agg(id) as ids,
    string_agg(number, ';') AS permit_number,
    shipment_number
    from trade_permits
    where legacy_reporter_type = '#{v}'
    group by shipment_number) AS a
    where legacy_shipment_number = a.shipment_number
    SQL
    puts "Inserting #{k} permits into trade_shipments"
    execute_query(sql)
  end
end
