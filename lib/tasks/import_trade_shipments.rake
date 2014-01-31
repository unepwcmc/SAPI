namespace :import do
  desc "Import names from csv file"
  task :names_for_trade => [:environment] do
    TMP_TABLE = "names_for_transfer_import"
    file = "lib/files/names_for_transfer.csv"
    drop_table(TMP_TABLE)
    create_table_from_csv_headers(file, TMP_TABLE)
    copy_data(file, TMP_TABLE)
  end

  desc "Import unusual geo_entities"
  task :unusual_geo_entities => [:environment] do
    GeoEntityType.find_or_create_by_name('TRADE_ENTITY')
    CSV.foreach("lib/files/former_and_adapted_geo_entities.csv", :headers => true) do |row|
      GeoEntity.find_or_create_by_iso_code2(
        iso_code2: row[1],
        geo_entity_type_id: GeoEntityType.where(name: row[5]).first.id,
        name_en: row[0],
        name_fr: row[2],
        name_es: row[3],
        long_name: row[4],
        legacy_type: row[5],
        is_current: row[6]
      )
    end
  end

  desc "Import first shipments from csv file (usage: rake import:shipments[path/to/file])"
  task :shipments, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    puts "opening file"

    TMP_TABLE = "shipments_import"

    files = files_from_args(t, args)
    files.each do |file|
      Sapi::Indexes.drop_indexes_on_shipments
      drop_create_and_copy_temp(TMP_TABLE, file)
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
      update_country_codes
      populate_shipments
      Sapi::Indexes.create_indexes_on_shipments
    end
  end


end


def drop_create_and_copy_temp(tmp_table, file)
  puts "Creating temp table"
  drop_table(tmp_table)
  create_table_from_csv_headers(file, tmp_table)
  copy_data(file, tmp_table)
end

def update_country_codes
  sql = <<-SQL
    UPDATE shipments_import
    SET export_country_code = 'ZZ'
    WHERE export_country_code = '*S';
    UPDATE shipments_import
    SET origin_country_code = 'ZZ'
    WHERE origin_country_code = '*S';
    UPDATE shipments_import
    SET export_country_code = 'MF'
    WHERE export_country_code = 'FR' AND import_country_code = 'XA' AND reporter_type = 'E';
    UPDATE shipments_import
    SET export_country_code = 'MF'
    WHERE export_country_code = 'KN' AND import_country_code = 'XA' AND reporter_type = 'E';
    UPDATE shipments_import
    SET export_country_code = 'DE'
    WHERE export_country_code = 'AU' AND import_country_code = 'DD' AND reporter_type = 'E' AND shipment_year = 1998;
    UPDATE shipments_import
    SET export_country_code = 'XX'
    WHERE export_country_code = 'AU' OR import_country_code = 'DD' AND reporter_type = 'E' AND shipment_year = 1998;
    UPDATE shipments_import
    SET export_country_code = 'XX'
    WHERE export_country_code IN ('XA', 'XC', 'XE', 'XF', 'XM', 'XS');
    UPDATE shipments_import
    SET import_country_code = 'XX'
    WHERE import_country_code IN ('XA', 'XC', 'XE', 'XF', 'XM', 'XS');
    UPDATE shipments_import
    SET origin_country_code = 'XX'
    WHERE origin_country_code IN ('XA', 'XC', 'XE', 'XF', 'XM', 'XS');
    UPDATE shipments_import
    SET origin_country_code = 'XK'
    WHERE export_country_code = 'KX';
    UPDATE shipments_import
    SET import_country_code = 'XK'
    WHERE import_country_code = 'KX';
    UPDATE shipments_import
    SET origin_country_code = 'XK'
    WHERE origin_country_code = 'KX';
    DELETE FROM shipments_import
    WHERE quantity_1 IS NULL;
  SQL
  ActiveRecord::Base.connection.execute(sql)
  puts "Cleaning Up Import Table"
end

def populate_shipments
  puts "Inserting into trade_shipments table"
  xx_id = GeoEntity.find_by_iso_code2('XX').id
  sql = <<-SQL
    INSERT INTO trade_shipments(
      legacy_shipment_number,
      source_id,
      unit_id,
      purpose_id,
      term_id ,
      quantity,
      appendix,
      exporter_id,
      importer_id,
      country_of_origin_id,
      reported_by_exporter,
      year,
      taxon_concept_id,
      created_at,
      updated_at,
      reported_taxon_concept_id)
    SELECT
      si.shipment_number as legacy_shipment_number,
      sources.id AS source_id,
      units.id AS unit_id,
      purposes.id AS purpose_id,
      terms.id AS term_id,
      quantity_1,
      CASE
        WHEN appendix='1' THEN 'I'
        WHEN appendix='2' THEN 'II'
        WHEN appendix='3' THEN 'III'
        WHEN appendix='0' THEN '0'
        WHEN appendix='N' THEN 'N'
        WHEN appendix IS NULL THEN 'Null'
      END AS appendix,
      CASE
        WHEN exporters.id IS NULL THEN #{xx_id}
        ELSE exporters.id
      END AS exporter_id,
      CASE
        WHEN importers.id IS NULL THEN #{xx_id}
        ELSE importers.id
      END AS importer_id,
      CASE
        WHEN origins.id IS NULL THEN #{xx_id}
        ELSE origins.id
      END AS country_of_origin_id,
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
    INNER JOIN taxon_concepts tc ON species_plus_id = tc.id
    LEFT JOIN trade_codes AS sources ON si.source_code = sources.code
      AND sources.type = 'Source'
    LEFT JOIN trade_codes AS units ON si.unit_code_1 = units.code
      AND units.type = 'Unit'
    LEFT JOIN trade_codes AS purposes ON si.purpose_code = purposes.code
      AND purposes.type = 'Purpose'
    INNER JOIN trade_codes AS terms ON si.term_code_1 = terms.code
      AND terms.type = 'Term'
    LEFT JOIN geo_entities AS exporters ON si.export_country_code = exporters.iso_code2
    LEFT JOIN geo_entities AS importers ON si.import_country_code = importers.iso_code2
    LEFT JOIN geo_entities AS origins ON si.origin_country_code = origins.iso_code2
    LEFT JOIN
    (SELECT tr.taxon_concept_id,
      si.shipment_number
      FROM shipments_import si
      INNER JOIN names_for_transfer_import nti ON si.cites_taxon_code = nti.cites_taxon_code AND rank = '0'
      INNER JOIN taxon_relationships tr ON other_taxon_concept_id = nti.species_plus_id
      INNER JOIN taxon_relationship_types trt ON trt.id = taxon_relationship_type_id AND trt.name = 'HAS_SYNONYM'
      ) jt ON jt.shipment_number = si.shipment_number
    WHERE (rank = '0' AND jt.taxon_concept_id IS NOT NULL) OR (rank <> '0' AND tc.id IS NOT NULL)
  SQL
  ActiveRecord::Base.connection.execute(sql)
  puts "Populating trade_shipments"
end
