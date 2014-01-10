  namespace :import do
      desc "Import trade permits from csv file"
      task :trade_permits => [:environment] do
        TMP_TABLE = "permits_import"
        file = "lib/files/permit_details.csv"
        drop_table(TMP_TABLE)
        create_table_from_csv_headers(file, TMP_TABLE)
        copy_data(file, TMP_TABLE)

        sql = <<-SQL 
          CREATE INDEX index_permits_import_on_shipment_number
          ON permits_import
          USING btree
          (shipment_number);
          INSERT INTO trade_permits(
            number, 
            geo_entity_id, 
            legacy_entity_code)
          SELECT permit_number, 
            CASE 
            WHEN permit_reporter_type = 'E' THEN exporter_id
            WHEN permit_reporter_type = 'I' THEN importer_id
            WHEN permit_reporter_type = 'O' THEN country_of_origin_id
          END
          AS geo_entity_id, 
          entity_code AS legacy_entity_code
          FROM permits_import 
          LEFT JOIN trade_shipments ON shipment_number = legacy_shipment_number
        SQL
      end

  end