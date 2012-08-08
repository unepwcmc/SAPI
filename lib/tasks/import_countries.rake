namespace :import do

  ## When I first tried to import the countries file I got an error related with character encoding
  ## I've then followed the instructions in this stackoverflow answer: http://stackoverflow.com/questions/4867272/invalid-byte-sequence-for-encoding-utf8
  ## So:
  ### 1- check current character encoding with: file path/to/file
  ### 2- change character encoding: iconv -f original_charset -t utf-8 originalfile > newfile
  desc 'Import countries from csv file [usage: rake import:countries[path/to/file,path/to/another]'
  task :countries, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'countries_import'
    country_type = GeoEntityType.find_by_name(GeoEntityType::COUNTRY)
    puts "There are #{GeoEntity.count(conditions: {geo_entity_type_id: country_type.id})} countries in the database."
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_import_table(TMP_TABLE)
      copy_data_from_file(TMP_TABLE, file)
      sql = <<-SQL
          INSERT INTO geo_entities(name, iso_code2, iso_code3, geo_entity_type_id, legacy_id, legacy_type, created_at, updated_at)
          SELECT DISTINCT INITCAP(BTRIM(TMP.name)), INITCAP(BTRIM(TMP.iso2)), INITCAP(BTRIM(TMP.iso3)), #{country_type.id}, TMP.legacy_id, '#{GeoEntityType::COUNTRY}', current_date, current_date
          FROM #{TMP_TABLE} AS TMP
          WHERE NOT EXISTS (
          SELECT * FROM geo_entities
          WHERE legacy_id = TMP.legacy_id AND legacy_type = '#{GeoEntityType::COUNTRY}'
          );
      SQL
      ActiveRecord::Base.connection.execute(sql)
      link_countries()
    end
    puts "There are now #{GeoEntity.count(conditions: {geo_entity_type_id: country_type.id})} countries in the database"
  end

end

def link_countries
  puts "Going to link countries to the respective CITES Region"
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
      public.countries_import,
      public.geo_entities,
      public.geo_entity_types,
      public.geo_relationship_types,
      public.geo_entities as countries
    WHERE
      geo_entity_types.id = geo_entities.geo_entity_type_id AND
      geo_entity_types."name" ilike '#{GeoEntityType::CITES_REGION}' AND
      geo_entities."name" LIKE countries_import.region_number||'%' AND
      geo_relationship_types."name" ilike '#{GeoRelationshipType::CONTAINS}' AND
      countries.legacy_id = countries_import.legacy_id AND countries.legacy_type ilike '#{GeoEntityType::COUNTRY}' AND
      NOT EXISTS (
        SELECT *
        FROM geo_relationships
        WHERE geo_entity_id = geo_entities.id AND other_geo_entity_id = countries.id AND geo_relationship_type_id = geo_relationship_types.id
      );
  SQL
  puts "There are #{GeoRelationship.count} geo_relationships in the database."
  ActiveRecord::Base.connection.execute(sql)
  puts "There are now #{GeoRelationship.count} geo_relationships in the database."
end

