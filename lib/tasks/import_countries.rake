namespace :import do

  ## When I first tried to import the countries file I got an error related with character encoding
  ## I've then followed the instructions in this stackoverflow answer: http://stackoverflow.com/questions/4867272/invalid-byte-sequence-for-encoding-utf8
  ## So:
  ### 1- check current character encoding with: file path/to/file
  ### 2- change character encoding: iconv -f original_charset -t utf-8 originalfile > newfile
  desc 'Import countries from csv file [usage: FILE=[path/to/file] rake import:countries'
  task :countries => [:environment, "countries:copy_data", "countries:insert_geo_entity_types"] do
    TMP_TABLE = 'countries_import'
    puts "There are #{GeoEntity.count} countries in the database."
    country_type = GeoEntityType.find_by_name('COUNTRY')
    sql = <<-SQL
      INSERT INTO geo_entities(name, iso_code2, iso_code3, geo_entity_type_id, legacy_id, legacy_type, created_at, updated_at)
      SELECT DISTINCT INITCAP(BTRIM(TMP.name)), INITCAP(BTRIM(TMP.iso2)), INITCAP(BTRIM(TMP.iso3)), #{country_type.id}, TMP.legacy_id, 'COUNTRY', current_date, current_date
      FROM #{TMP_TABLE} AS TMP
      WHERE NOT EXISTS (
        SELECT * FROM geo_entities
        WHERE legacy_id = TMP.legacy_id AND legacy_type = 'COUNTRY'
      );
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "There are now #{GeoEntity.count} countries in the database"
  end

  namespace :countries do
    desc 'Inserts basic geo entity types'
    task :insert_geo_entity_types do
    puts "There are #{GeoEntityType.count} geo entity types in the database."
    ['COUNTRY','SUB_NATIONAL','REGION','BRU','AQUATIC'].each do |t|
      sql = <<-SQL
        INSERT INTO geo_entity_types(name, created_at, updated_at)
        SELECT '#{t}', current_date, current_date
        WHERE NOT EXISTS (
          SELECT * FROM geo_entity_types
          WHERE name = '#{t}'
        );
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end
    puts "There are now #{GeoEntityType.count} geo entity types in the database"
    end
    desc 'Creates countries_import table'
    task :create_table => :environment do
      TMP_TABLE = 'countries_import'
      begin
        puts "Creating tmp table: #{TMP_TABLE}"
        ActiveRecord::Base.connection.execute "CREATE TABLE #{TMP_TABLE} ( legacy_id integer, iso2 varchar, iso3 varchar, name varchar, long_name varchar);"
        puts "Table created"
      rescue Exception => e
        puts "Tmp already exists removing data from tmp table before starting the import"
        ActiveRecord::Base.connection.execute "DELETE FROM #{TMP_TABLE};"
        puts "Data removed"
      end
    end
    desc 'Copy data into countries_import table'
    task :copy_data => :create_table do
      TMP_TABLE = 'countries_import'
      if !ENV["FILE"] || !File.file?(Rails.root+ENV["FILE"]) #if the file is not defined, explain and leave.
        puts "Please specify a valid csv file from which to import countries data"
        puts "Usage: FILE=[path/to/file] rake import:countries"
        next
      end
      puts "Copying data from #{ENV["FILE"]} into tmp table #{TMP_TABLE}"
      psql = <<-PSQL
\\COPY #{TMP_TABLE} ( legacy_id, iso2, iso3, name, long_name)
  FROM '#{Rails.root + ENV["FILE"]}'
  WITH DElIMITER ','
  CSV HEADER;
PSQL
      db_conf = YAML.load(File.open(Rails.root + "config/database.yml"))[Rails.env]
      system("export PGPASSWORD=#{db_conf["password"]} && psql -h #{db_conf["host"] || "localhost"} -U#{db_conf["username"]} -c \"#{psql}\" #{db_conf["database"]}")
      puts "Data copied to tmp table"
    end
    desc 'Removes countries_import table'
    task :remove_table => :environment do
      TMP_TABLE = 'countries_import'
      begin
        ActiveRecord::Base.connection.execute "DROP TABLE #{TMP_TABLE};"
        puts "Table removed"
      rescue Exception => e
        puts "Could not drop table #{TMP_TABLE}. It might not exist if this is the first time you are running this rake task."
      end
    end
  end
end
