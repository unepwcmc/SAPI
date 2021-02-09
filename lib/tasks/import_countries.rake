namespace :import do

  ## When I first tried to import the countries file I got an error related with character encoding
  ## I've then followed the instructions in this stackoverflow answer: http://stackoverflow.com/questions/4867272/invalid-byte-sequence-for-encoding-utf8
  ## So:
  ### 1- check current character encoding with: file path/to/file
  ### 2- change character encoding: iconv -f original_charset -t utf-8 originalfile > newfile
  desc 'Import countries from csv file (usage: rake import:countries[path/to/file,path/to/another])'
  task :countries, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'countries_import'
    country_type = GeoEntityType.find_by_name(GeoEntityType::COUNTRY)
    territory_type = GeoEntityType.find_by_name(GeoEntityType::TERRITORY)
    puts "There are #{GeoEntity.count(conditions: { geo_entity_type_id: country_type.id })} countries in the database."
    puts "There are #{GeoEntity.count(conditions: { geo_entity_type_id: territory_type.id })} territories in the database."
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)
      sql = <<-SQL
          INSERT INTO geo_entities(name_en, iso_code2, geo_entity_type_id, legacy_type, created_at, updated_at, long_name, is_current)
          SELECT DISTINCT BTRIM(TMP.name), BTRIM(TMP.iso2), geo_entity_types.id, UPPER(BTRIM(geo_entity_type)),
          current_date, current_date, INITCAP(BTRIM(TMP.long_name)),
          CASE
            WHEN UPPER(BTRIM(current_name)) = 'Y' THEN TRUE
            ELSE FALSE
          END
          FROM #{TMP_TABLE} AS TMP
          INNER JOIN geo_entity_types ON geo_entity_types.name = UPPER(BTRIM(geo_entity_type))
          WHERE NOT EXISTS (
            SELECT * FROM geo_entities
            WHERE UPPER(geo_entities.iso_code2) = UPPER(BTRIM(TMP.iso2)) AND geo_entities.legacy_type = UPPER(BTRIM(geo_entity_type))
          )
      SQL
      ActiveRecord::Base.connection.execute(sql)
      link_countries
    end
    puts "There are now #{GeoEntity.count(conditions: { geo_entity_type_id: country_type.id })} countries in the database"
    puts "There are now #{GeoEntity.count(conditions: { geo_entity_type_id: territory_type.id })} territories in the database."
  end

  desc "Add country names in spanish and french"
  task :countries_translations => [:environment] do
    CSV.foreach("lib/files/country_codes_en_es_fr_utf8.csv") do |row|
      country = GeoEntity.find_or_initialize_by(iso_code2: row[0].strip.upcase)
      unless country.id.nil?
        country.update_attributes(
          :name_fr => row[1].strip, :name_es => row[2].strip
        )
      end
    end
    puts "Countries updated with french and spanish names"
  end
end

def link_countries
  puts "Link territories to countries and countries to respective CITES regions"
  puts "There are #{GeoRelationship.count} geo_relationships in the database."
  sql = <<-SQL
    INSERT INTO geo_relationships(geo_entity_id, other_geo_entity_id, geo_relationship_type_id, created_at, updated_at)
    SELECT
      DISTINCT
      geo_entities.id,
      countries.id,
      geo_relationship_types.id,
      current_date,
      current_date
    FROM
      public.#{TMP_TABLE},
      public.geo_entities,
      public.geo_entity_types,
      public.geo_relationship_types,
      public.geo_entities as countries
    WHERE
      geo_entity_types.id = geo_entities.geo_entity_type_id AND
      geo_entity_types."name" = '#{GeoEntityType::CITES_REGION}' AND
      geo_entities."name_en" LIKE #{TMP_TABLE}.cites_region||'%' AND
      geo_relationship_types."name" = '#{GeoRelationshipType::CONTAINS}' AND
      countries.iso_code2 = UPPER(BTRIM(#{TMP_TABLE}.iso2)) AND
      UPPER(BTRIM(countries.legacy_type)) = '#{GeoEntityType::COUNTRY}' AND
      NOT EXISTS (
        SELECT *
        FROM geo_relationships
        WHERE geo_entity_id = geo_entities.id AND other_geo_entity_id = countries.id AND
        geo_relationship_type_id = geo_relationship_types.id
      );
  SQL
  ActiveRecord::Base.connection.execute(sql)

  sql = <<-SQL
    INSERT INTO geo_relationships(geo_entity_id, other_geo_entity_id, geo_relationship_type_id, created_at, updated_at)
    SELECT
      DISTINCT
      geo_entities.id,
      territories.id,
      geo_relationship_types.id,
      current_date,
      current_date
    FROM
      public.#{TMP_TABLE},
      public.geo_entities,
      public.geo_entity_types,
      public.geo_relationship_types,
      public.geo_entities as territories
    WHERE
      geo_entity_types.id = geo_entities.geo_entity_type_id AND
      geo_entity_types."name" = '#{GeoEntityType::COUNTRY}' AND
      UPPER(geo_entities."iso_code2") = UPPER(BTRIM(#{TMP_TABLE}.parent_iso_code2)) AND
      geo_relationship_types."name" = '#{GeoRelationshipType::CONTAINS}' AND
      territories.iso_code2 = UPPER(BTRIM(#{TMP_TABLE}.iso2)) AND
      UPPER(BTRIM(territories.legacy_type)) = '#{GeoEntityType::TERRITORY}' AND
      NOT EXISTS (
        SELECT *
        FROM geo_relationships
        WHERE geo_entity_id = geo_entities.id AND other_geo_entity_id = territories.id AND
        geo_relationship_type_id = geo_relationship_types.id
      );
  SQL
  ActiveRecord::Base.connection.execute(sql)

  puts "There are now #{GeoRelationship.count} geo_relationships in the database."
end
