namespace :import do

  desc "Import CITES Regions records from csv file [usage: FILE=[path/to/file] rake import:cites_regions"
  task :cites_regions => [:environment, "cites_regions:copy_data"] do
    TMP_TABLE = 'cites_regions_import'
    regions_type = GeoEntityType.find_by_name(GeoEntityType::CITES_REGION)
    puts "There are #{GeoEntity.count(conditions: {geo_entity_type_id: regions_type.id})} CITES Regions in the database."
    sql = <<-SQL
      INSERT INTO geo_entities(name, geo_entity_type_id, created_at, updated_at)
      SELECT DISTINCT INITCAP(BTRIM(TMP.name)), #{regions_type.id}, current_date, current_date
      FROM #{TMP_TABLE} AS TMP
      WHERE NOT EXISTS (
        SELECT * FROM geo_entities
        WHERE INITCAP(BTRIM(name)) = INITCAP(BTRIM(TMP.name)) AND geo_entity_type_id = #{regions_type.id}
      );
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "There are now #{GeoEntity.count(conditions: {geo_entity_type_id: regions_type.id})} CITES Regions in the database"
  end

  namespace :cites_regions do
    desc 'Creates cites_regions_import table'
    task :create_table => :environment do
      file= ENV["FILE"] || 'lib/assets/files/cites_regions.csv'
      create_table_from_csv_headers(file, 'cites_regions_import')
    end

    desc 'Copy data into cites_regions_import table'
    task :copy_data => :create_table do
      file = ENV["FILE"] || 'lib/assets/files/cites_regions.csv'
      if !file || !File.file?(Rails.root+file) #if the file is not defined, explain and leave.
        puts "Please specify a valid csv file from which to import cites_regions data"
        puts "Usage: FILE=[path/to/file] rake import:cites_regions"
        next
      end
      copy_data(file, 'cites_regions_import')
    end
    desc 'Removes cites_regions_import table'
    task :remove_table => :environment do
      drop_table('cites_regions_import')
    end
  end
end
