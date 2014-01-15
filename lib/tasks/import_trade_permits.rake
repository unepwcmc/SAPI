  namespace :import do
      desc "Import trade permits from csv file"
      task :trade_permits => [:environment] do
        #TMP_TABLE = "permits_import"
        #file = "lib/files/permit_details.csv"
        #drop_table(TMP_TABLE)
        #create_table_from_csv_headers(file, TMP_TABLE)
        #copy_data(file, TMP_TABLE)

        sql = <<-SQL
        ALTER TABlE trade_permits ADD COLUMN shipment_number int;
        INSERT INTO trade_permits (number, shipment_number, legacy_reporter_type, created_At, updated_at)
        SELECT permit_number,
               shipment_number,
               legacy_reporter_type,
               now()::date AS created_at,
               now()::date AS updated_at
        FROM permits_import;
        SQL
        ActiveRecord::Base.connection.execute(sql)

        sql = <<-SQL
        CREATE INDEX index_permits_import_on_permit_number
        ON permits_import
        USING btree
        (permit_number);   
        CREATE INDEX index_permits_import_on_shipment_number
        ON permits_import
        USING btree
        (shipment_number);
        CREATE INDEX index_permits_import_on_legacy_reporter_type
        ON permits_import
        USING btree
        (legacy_reporter_type);
        SQL

        permits_entity = {"import" => "I", "export" => 'E', "origin" => 'O'}
        permits_entity.each do |k,v|

          sql = <<-SQL          
          UPDATE trade_shipments
          SET #{k}_permit_number = array
          FROM (SELECT array_agg(number) array, 
          shipment_number 
          from trade_permits
          where type = #{v})
          group by shipment_number) a
          where legacy_shipment_number = a.shipment_number
          SQL
          ActiveRecord::Base.connection.execute(sql)
          
        end

        sql = <<-SQL
        ALTER TABlE trade_permits DROP COLUMN shipment_number;
        SQL
        ActiveRecord::Base.connection.execute(sql)


                

        #Trade::Permi.select(:legacy_shipment_number).joins("INNER JOIN permits_import ON legacy_shipment_number = shipment_number limit 10").each do |number|
        #sql = <<-SQL                
        #  UPDATE trade_shipments SET export_permits_ids = s.array FROM 
        #  (SELECT #{number.legacy_shipment_number} as number, ARRAY(SELECT permit_number 
        #            FROM trade_permits inner join permits_import WHERE shipment_number = #{number.legacy_shipment_number} and permits_import.permit_type = 'E')) s
        #  WHERE legacy_shipment_number = s.number
        #SQL
        #puts ActiveRecord::Base.connection.execute(sql).first
        
      end
  end
end