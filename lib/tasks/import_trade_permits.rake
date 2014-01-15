namespace :import do
    desc "Import trade permits from csv file"
    task :trade_permits => [:environment] do
      TMP_TABLE = "permits_import"
      file = "lib/files/permit_details.csv"
      permits_import_to_index = {"permits_import" => ["permit_number", "shipment_number", "permit_reporter_type"]}
      trade_permits_to_index = {"trade_permits" => ["shipment_number", "legacy_reporter_type"]}

      delete_shipment_number_tmp_column
      drop_indices(trade_permits_to_index)
      drop_indices(permits_import_to_index)
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)
      add_shipment_number_tmp_column
      create_indices(permits_import_to_index)
      populate_trade_permits
      create_indices(trade_permits_to_index)
      insert_into_trade_shipments
      drop_indices(permits_import_to_index)
      drop_indices(trade_permits_to_index)
      delete_shipment_number_tmp_column
  end
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
    SET #{k}_permit_number = permit_number
    FROM (SELECT array_agg(id) id, 
    shipment_number 
    from trade_permits
    where legacy_reporter_type = '#{v}'
    group by shipment_number) a
    where legacy_shipment_number = a.shipment_number
    SQL
    puts "Inserting into trade_shipments"
    execute_query(sql)
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
      puts "Dropping index #{index}"
      execute_query(sql)
    end
  end
end

def create_indices(table_columns)
  table_columns.each do |table,columns|
    columns.each do |column|
      sql = <<-SQL
      CREATE INDEX index_#{table}_on_#{column}
      ON #{table}
      USING btree
      (#{column});   
      SQL
      puts "Creating index for #{column}"
      execute_query(sql)
    end
  end
end

def add_shipment_number_tmp_column
  sql = <<-SQL
  ALTER TABlE trade_permits ADD COLUMN shipment_number int;
  SQL
  execute_query(sql)
end
def delete_shipment_number_tmp_column
  sql = <<-SQL 
  ALTER TABlE trade_permits DROP COLUMN shipment_number;
  SQL
  execute_query(sql)
end
