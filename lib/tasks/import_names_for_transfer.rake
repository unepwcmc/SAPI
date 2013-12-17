  namespace :import do
      desc "Import names from csv file"
      task :names_for_transfer => [:environment] do
        TMP_TABLE = "names_for_transfer_import"
        file = "lib/files/names_for_transfer.csv"
        drop_table(TMP_TABLE)
        create_table_from_csv_headers(file, TMP_TABLE)
        copy_data(file, TMP_TABLE)
      end

      desc "Import unusual geo_entities"
      task :unusual_geo_entities => [:environment] do
        CSV.foreach("lib/files/former_and_adapted_geo_entities.csv", :headers => true) do |row|
          puts GeoEntity.find_or_create_by_iso_code2(
            iso_code2: row[1],
            geo_entity_type_id:  GeoEntityType.where(name: row[5]).first.id,
            name_en: row[0], 
            name_fr: row[2], 
            name_es: row[3], 
            long_name: row[4], 
            legacy_type: row[5], 
            is_current: row[6]
            )
        end
      end


      desc "Import shipments from csv file"
        task :shipments => [:environment] do
          TMP_TABLE = "shipments_import"
          file = "lib/files/SHIPMENT_DETAILS_DATA_TABLE.csv"
          drop_table(TMP_TABLE)
          create_table_from_csv_headers(file, TMP_TABLE)
          copy_data(file, TMP_TABLE)

          sql = <<-SQL
            DELETE FROM shipments_import  WHERE shipment_number =  8122168;
          SQL
          ActiveRecord::Base.connection.execute(sql)

          fix_term_codes = {12227624 => "LIV", 12225022 => "DER", 12224783 => "DER"}
          fix_term_codes.each do |shipment_number,term_code|
            sql = <<-SQL
              UPDATE shipments_import SET term_code_1 = '#{term_code}' WHERE shipment_number =  #{shipment_number};
            SQL
            ActiveRecord::Base.connection.execute(sql)
          end
        end


      desc "Import shipments from csv file"
        task :populate_shipments => [:environment] do
          sql = <<-SQL
          DELETE from  trade_shipments;
          INSERT INTO trade_shipments(
          source_id,
          unit_id,
          purpose_id,
          term_id ,
          quantity,
          appendix,
          exporter_id,
          importer_id,
          country_of_origin_id ,
          reported_by_exporter,
          taxon_concept_id,
          year,
          created_at,
          updated_at,
          reported_taxon_concept_id)
SELECT sources.id AS source_id,
       units.id AS unit_id,
       purposes.id AS purpose_id,
       terms.id AS term_id,
       quantity_1,
       CASE
           WHEN appendix='1' THEN 'I'
           WHEN appendix='2' THEN 'II'
           WHEN appendix='3' THEN 'III'
           ELSE 'other'
       END AS appendix ,
       exporters.id AS exporter_id,
       importers.id AS importer_id,
       origins.id AS country_of_origin_id,
       CASE
           WHEN reporter_type = 'E' THEN TRUE
           ELSE FALSE
       END AS reported_by_exporter,
       shipment_year AS YEAR,
        CASE
           WHEN rank = '0' THEN jt.taxon_concept_id
           ELSE species_plus_id
       END AS taxon_concept_id,
       to_date(shipment_year::varchar, 'yyyy') AS created_at,
       to_date(shipment_year::varchar, 'yyyy') AS updated_at,
       species_plus_id AS reported_taxon_concept_id

FROM shipments_import si
INNER JOIN names_for_transfer_import nti ON si.cites_taxon_code = nti.cites_taxon_code
LEFT JOIN trade_codes AS sources ON si.source_code = sources.code
AND sources.type = 'Source'
LEFT JOIN trade_codes AS units ON si.unit_code_1 = units.code
AND units.type = 'Unit'
LEFT JOIN trade_codes AS purposes ON si.purpose_code = purposes.code
AND purposes.type = 'Purpose'
LEFT JOIN trade_codes AS terms ON si.term_code_1 = terms.code
AND terms.type = 'Term'
LEFT JOIN geo_entities AS exporters ON si.export_country_code = exporters.iso_code2
LEFT JOIN geo_entities AS importers ON si.import_country_code = importers.iso_code2
LEFT JOIN geo_entities AS origins ON si.import_country_code = origins.iso_code2
LEFT JOIN
  (SELECT tr.taxon_concept_id,
          si.shipment_number
   FROM shipments_import si
   INNER JOIN names_for_transfer_import nti ON si.cites_taxon_code = nti.cites_taxon_code
   INNER JOIN taxon_relationships tr ON other_taxon_concept_id = nti.species_plus_id) jt ON jt.shipment_number = si.shipment_number ;
        SQL
  ActiveRecord::Base.connection.execute(sql)
  end
end