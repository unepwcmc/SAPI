namespace :import do

  desc 'Import distributions from csv file [usage: FILE=[path/to/file] rake import:distributions'
  task :distributions => [:environment, "distributions:copy_data"] do
    TMP_TABLE = 'distribution_import'
    puts "There are #{TaxonConceptGeoEntity.count} taxon concept distributions in the database."
    sql = <<-SQL
      INSERT INTO taxon_concept_geo_entities(taxon_concept_id, geo_entity_id, created_at, updated_at)
      SELECT DISTINCT species.id, geo_entities.id, current_date, current_date
        FROM #{TMP_TABLE}
        LEFT JOIN geo_entities ON geo_entities.legacy_id = country_id AND geo_entities.legacy_type = '#{GeoEntityType::COUNTRY}'
        LEFT JOIN taxon_concepts as species ON species.legacy_id = species_id
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "There are now #{TaxonConceptGeoEntity.count} taxon concept distributions in the database"
  end

  namespace :distributions do
    desc 'Creates distribution_import table'
    task :create_table => :environment do
      TMP_TABLE = 'distribution_import'
      begin
        puts "Creating tmp table: #{TMP_TABLE}"
        ActiveRecord::Base.connection.execute "CREATE TABLE #{TMP_TABLE} ( species_id integer, country_id integer, country_name varchar);"
        puts "Table created"
      rescue Exception => e
        puts "Tmp already exists removing data from tmp table before starting the import"
        ActiveRecord::Base.connection.execute "DELETE FROM #{TMP_TABLE};"
        puts "Data removed"
      end
    end
    desc 'Copy data into distribution_import table'
    task :copy_data => :create_table do
      TMP_TABLE = 'distribution_import'
      file = ENV["FILE"] || 'lib/assets/files/animals_distributions.csv'
      if !file || !File.file?(Rails.root+file) #if the file is not defined, explain and leave.
        puts "Please specify a valid csv file for the distribution from which to import distribution data"
        puts "Usage: FILE=[path/to/file] rake import:distributions"
        next
      end
      puts "Copying data from #{file} into tmp table #{TMP_TABLE}"
      psql = <<-PSQL
\\COPY #{TMP_TABLE} (species_id, country_id, country_name)
          FROM '#{Rails.root + file}'
          WITH DElIMITER ','
          CSV HEADER
      PSQL
      db_conf = YAML.load(File.open(Rails.root + "config/database.yml"))[Rails.env]
      system("export PGPASSWORD=#{db_conf["password"]} && psql -h #{db_conf["host"] || "localhost"} -U#{db_conf["username"]} -c \"#{psql}\" #{db_conf["database"]}")
      puts "Data copied to tmp table"
    end
    desc 'Removes distribution_import table'
    task :remove_table => :environment do
      TMP_TABLE = 'distribution_import'
      begin
        ActiveRecord::Base.connection.execute "DROP TABLE #{TMP_TABLE};"
        puts "Table removed"
      rescue Exception => e
        puts e.message
        puts "Could not drop table #{TMP_TABLE}. It might not exist if this is the first time you are running this rake task."
      end
    end
  end
end

