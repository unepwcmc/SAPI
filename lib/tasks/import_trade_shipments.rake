namespace :import do

  desc "Import unusual geo_entities"
  task :unusual_geo_entities => [:environment] do
    GeoEntityType.find_or_create_by(name: 'TRADE_ENTITY')
    CSV.foreach("lib/files/former_and_adapted_geo_entities.csv", :headers => true) do |row|
      GeoEntity.find_or_create_by(
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

  desc "Import shipments from csv file (usage: rake import:shipments[path/to/file])"
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
      fix_term_codes = { 12227624 => "LIV", 12225022 => "DER", 12224783 => "DER" }
      fix_term_codes.each do |shipment_number, term_code|
        sql = <<-SQL
          UPDATE shipments_import SET term_code_1 = '#{term_code}' WHERE shipment_number =  #{shipment_number};
        SQL
        ActiveRecord::Base.connection.execute(sql)
      end
      update_country_codes
      populate_shipments
      populate_shipments_for_trade_names
      Sapi::Indexes.create_indexes_on_shipments
    end
  end

  desc "Import shipments for Trade Names from csv file (usage: rake import:shipmets[path/to/file])"
  task :shipments_for_trade_names, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
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
      fix_term_codes = { 12227624 => "LIV", 12225022 => "DER", 12224783 => "DER" }
      fix_term_codes.each do |shipment_number, term_code|
        sql = <<-SQL
          UPDATE shipments_import SET term_code_1 = '#{term_code}' WHERE shipment_number =  #{shipment_number};
        SQL
        ActiveRecord::Base.connection.execute(sql)
      end
      update_country_codes
      # populate_shipments
      populate_shipments_for_trade_names
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
    -- all records with exporter *S should be changed to exporter ZZ (introduction from the sea).
    UPDATE shipments_import
    SET export_country_code = 'ZZ'
    WHERE export_country_code = '*S';

    -- all records with origin *S should be changed to origin ZZ (introduction from the sea).
    UPDATE shipments_import
    SET origin_country_code = 'ZZ'
    WHERE origin_country_code = '*S';

    --All years, exporter FR, importer XA, reported by FR- amend XA to MF (37 records)
    UPDATE shipments_import
    SET import_country_code = 'MF'
    WHERE export_country_code = 'FR' AND import_country_code = 'XA' AND reporter_type = 'E';

    --All years, exporter KN, importer XA, reported by KN- amend XA to MF (238 records)
    UPDATE shipments_import
    SET import_country_code = 'MF'
    WHERE export_country_code = 'KN' AND import_country_code = 'XA' AND reporter_type = 'E';

    --1998, exporter AU, importer DD, reported by AU- change DD to DE (131 records)
    UPDATE shipments_import
    SET import_country_code = 'DE'
    WHERE export_country_code = 'AU' AND import_country_code = 'DD' AND reporter_type = 'E' AND shipment_year = 1998;

    --All records of exporter XA, XC, XE, XF, XM, XS- amend to XX
    UPDATE shipments_import
    SET export_country_code = 'XX'
    WHERE export_country_code IN ('XA', 'XC', 'XE', 'XF', 'XM', 'XS');

    --All records of importer XA, XC, XE, XF, XM, XS- amend to XX
    UPDATE shipments_import
    SET import_country_code = 'XX'
    WHERE import_country_code IN ('XA', 'XC', 'XE', 'XF', 'XM', 'XS');

    --All records of origin XA, XC, XE, XF, XM, XS- amend to XX
    UPDATE shipments_import
    SET origin_country_code = 'XX'
    WHERE origin_country_code IN ('XA', 'XC', 'XE', 'XF', 'XM', 'XS');

    -- exporter KX should be changed the XK and added as a Trade entity = entity Kosovo (disputed)
    UPDATE shipments_import
    SET export_country_code = 'XK'
    WHERE export_country_code = 'KX';

    -- importer KX should be changed the XK and added as a Trade export_country_codentity = Kosovo (disputed)
    UPDATE shipments_import
    SET import_country_code = 'XK'
    WHERE import_country_code = 'KX';

    -- origin KX should be changed the XK and added as a Tradede entity = Kosovo (disputed)
    UPDATE shipments_import
    SET origin_country_code = 'XK'
    WHERE origin_country_code = 'KX';

    DELETE FROM shipments_import
    WHERE quantity_1 IS NULL;
  SQL
  puts "Cleaning Up Import Table #{Time.now.strftime("%d/%m/%Y %H:%M")}"
  ActiveRecord::Base.connection.execute(sql)
end

def populate_shipments
  has_synonym = TaxonRelationshipType.where(:name => "HAS_SYNONYM").
    select(:id).first.id
  puts "Inserting into trade_shipments table"
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
        WHEN exporters.id IS NULL THEN NULL
        ELSE exporters.id
      END AS exporter_id,
      CASE
        WHEN importers.id IS NULL THEN NULL
        ELSE importers.id
      END AS importer_id,
      CASE
        WHEN origins.id IS NULL THEN NULL
        ELSE origins.id
      END AS country_of_origin_id,
      CASE
        WHEN reporter_type = 'E' THEN TRUE
        ELSE FALSE
      END AS reported_by_exporter,
      shipment_year AS YEAR,
      CASE
        WHEN tc.name_status = 'S'
          THEN taxon_relationships.taxon_concept_id
        WHEN tc.name_status = 'A' OR tc.name_status = 'H' OR tc.name_status = 'N'
          THEN tc.id
        ELSE NULL
      END AS taxon_concept_id,
      to_date(shipment_year::varchar, 'yyyy') AS created_at,
      to_date(shipment_year::varchar, 'yyyy') AS updated_at,
      tc.id AS reported_taxon_concept_id
    FROM shipments_import si

    INNER JOIN trade_species_mapping_import nti ON si.cites_taxon_code = nti.cites_taxon_code
    INNER JOIN taxon_concepts tc ON nti.species_plus_id = tc.id
    LEFT JOIN taxon_relationships ON taxon_relationships.other_taxon_concept_id = tc.id
      AND tc.name_status = 'S' AND taxon_relationships.taxon_relationship_type_id = #{has_synonym}

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
    WHERE (tc.name_status = 'A' OR tc.name_status = 'H' OR tc.name_status = 'N') OR
      (tc.name_status = 'S' AND taxon_relationships.other_taxon_concept_id = tc.id)
  SQL
  puts "Populating trade_shipments #{Time.now.strftime("%d/%m/%Y %H:%M")}"
  ActiveRecord::Base.connection.execute(sql)
end

def populate_shipments_for_trade_names
  puts "Inserting into trade_shipments Trade Names' shipments table"
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
        WHEN exporters.id IS NULL THEN NULL
        ELSE exporters.id
      END AS exporter_id,
      CASE
        WHEN importers.id IS NULL THEN NULL
        ELSE importers.id
      END AS importer_id,
      CASE
        WHEN origins.id IS NULL THEN NULL
        ELSE origins.id
      END AS country_of_origin_id,
      CASE
        WHEN reporter_type = 'E' THEN TRUE
        ELSE FALSE
      END AS reported_by_exporter,
      shipment_year AS YEAR,
      taxon_concepts.id AS taxon_concept_id,
      to_date(shipment_year::varchar, 'yyyy') AS created_at,
      to_date(shipment_year::varchar, 'yyyy') AS updated_at,
      reported_as.id AS reported_taxon_concept_id
    FROM shipments_import si

    INNER JOIN taxon_concepts reported_as ON reported_as.legacy_trade_code = si.cites_taxon_code
      AND reported_as.name_status = 'T'
    INNER JOIN taxon_relationships ON taxon_relationships.other_taxon_concept_id = reported_as.id
    INNER JOIN taxon_concepts ON taxon_concepts.id = taxon_relationships.taxon_concept_id
    INNER JOIN taxon_relationship_types ON taxon_relationship_types.id = taxon_relationships.taxon_relationship_type_id AND
      taxon_relationship_types.name = 'HAS_TRADE_NAME'

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
  SQL
  puts "Populating trade_shipments with Trade Names' shipments #{Time.now.strftime("%d/%m/%Y %H:%M")}"
  ActiveRecord::Base.connection.execute(sql)
end
