namespace :import do

  desc "Import CITES Regions records from csv file [usage: FILE=[path/to/file] rake import:cites_regions"
  task :cites_regions => [:environment, "cites_regions:copy_data"] do
    TMP_TABLE = 'cites_regions_import'
    regions_type = GeoEntityType.find_by_name('CITES REGION')
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
      TMP_TABLE = 'cites_regions_import'
      begin
        puts "Creating tmp table: #{TMP_TABLE}"
        ActiveRecord::Base.connection.execute "CREATE TABLE #{TMP_TABLE} ( name varchar);"
        puts "Table created"
      rescue Exception => e
        puts "Tmp already exists removing data from tmp table before starting the import"
        ActiveRecord::Base.connection.execute "DELETE FROM #{TMP_TABLE};"
        puts "Data removed"
      end
    end

    desc 'Copy data into cites_regions_import table'
    task :copy_data => :create_table do
      TMP_TABLE = 'cites_regions_import'
      file = ENV["FILE"] || 'lib/assets/files/cites_regions.csv'
      if !file || !File.file?(Rails.root+file) #if the file is not defined, explain and leave.
        puts "Please specify a valid csv file from which to import cites_regions data"
        puts "Usage: FILE=[path/to/file] rake import:cites_regions"
        next
      end
      puts "Copying data from #{file} into tmp table #{TMP_TABLE}"
      psql = <<-PSQL
\\COPY #{TMP_TABLE} (name)
          FROM '#{Rails.root + file}'
          WITH DElIMITER ','
          CSV HEADER
      PSQL
      db_conf = YAML.load(File.open(Rails.root + "config/database.yml"))[Rails.env]
      system("export PGPASSWORD=#{db_conf["password"]} && psql -h #{db_conf["host"] || "localhost"} -U#{db_conf["username"]} -c \"#{psql}\" #{db_conf["database"]}")
      puts "Data copied to tmp table"
    end
    desc 'Removes cites_regions_import table'
    task :remove_table => :environment do
      TMP_TABLE = 'cites_regions_import'
      begin
        ActiveRecord::Base.connection.execute "DROP TABLE #{TMP_TABLE};"
        puts "Table removed"
      rescue Exception => e
        puts "Could not drop table #{TMP_TABLE}. It might not exist if this is the first time you are running this rake task."
      end
    end
  end
end
