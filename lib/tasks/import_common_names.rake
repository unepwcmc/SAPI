namespace :import do

  desc 'Import common names from csv file [usage: FILE=[path/to/file] rake import:common_names'
  task :common_names => [:environment, "common_names:copy_data"] do
    TMP_TABLE = 'common_name_import'
    puts "There are #{CommonName.count} common names in the database."
    puts "There are #{TaxonCommon.count} taxon commons in the database."
    sql = <<-SQL
      INSERT INTO common_names(name, language_id, created_at, updated_at)
      SELECT common_name, languages.id, current_date, current_date
        FROM #{TMP_TABLE}
        LEFT JOIN languages ON #{TMP_TABLE}.language_name = languages.name
        WHERE NOT EXISTS (
          SELECT common_names.name
            FROM common_names
            LEFT JOIN languages ON common_names.language_id = languages.id
            WHERE common_names.name = #{TMP_TABLE}.common_name AND #{TMP_TABLE}.language_name = languages.name
        );

      INSERT INTO taxon_commons(taxon_concept_id, common_name_id, created_at, updated_at)
      SELECT DISTINCT species.id, common_names.id, current_date, current_date
        FROM #{TMP_TABLE}
        LEFT JOIN common_names ON #{TMP_TABLE}.common_name = common_names.name
        LEFT JOIN languages ON #{TMP_TABLE}.language_name = languages.name
        LEFT JOIN taxon_concepts as species ON species.legacy_id = species_id
        WHERE Species.id IS NOT NULL
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "There are now #{CommonName.count} common names in the database"
    puts "There are #{TaxonCommon.count} taxon commons in the database."
  end

  namespace :common_names do
    desc 'Creates common_name_import table'
    task :create_table => :environment do
      TMP_TABLE = 'common_name_import'
      begin
        puts "Creating tmp table: #{TMP_TABLE}"
        ActiveRecord::Base.connection.execute "CREATE TABLE #{TMP_TABLE} ( common_name varchar, language_name varchar, species_id integer);"
        puts "Table created"
      rescue Exception => e
        puts "Tmp already exists removing data from tmp table before starting the import"
        ActiveRecord::Base.connection.execute "DELETE FROM #{TMP_TABLE};"
        puts "Data removed"
      end
    end
    desc 'Copy data into common_name_import table'
    task :copy_data => :create_table do
      TMP_TABLE = 'common_name_import'
      file = ENV["FILE"] || 'lib/assets/files/animals_common_names.csv'
      if !file || !File.file?(Rails.root+file) #if the file is not defined, explain and leave.
        puts "Please specify a valid csv file for the common names from which to import common names data"
        puts "Usage: FILE=[path/to/file] rake import:common_names"
        next
      end
      puts "Copying data from #{file} into tmp table #{TMP_TABLE}"
      psql = <<-PSQL
\\COPY #{TMP_TABLE} (common_name, language_name, species_id)
          FROM '#{Rails.root + file}'
          WITH DElIMITER ','
          CSV HEADER
      PSQL
      db_conf = YAML.load(File.open(Rails.root + "config/database.yml"))[Rails.env]
      system("export PGPASSWORD=#{db_conf["password"]} && psql -h #{db_conf["host"] || "localhost"} -U#{db_conf["username"]} -c \"#{psql}\" #{db_conf["database"]}")
      puts "Data copied to tmp table"
    end
    desc 'Removes common_name_import table'
    task :remove_table => :environment do
      TMP_TABLE = 'common_name_import'
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

