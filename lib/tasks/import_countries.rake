namespace :import do

  ## When I first tried to import the countries file I got an error related with character encoding
  ## I've then followed the instructions in this stackoverflow answer: http://stackoverflow.com/questions/4867272/invalid-byte-sequence-for-encoding-utf8
  ## So:
  ### 1- check current character encoding with: file path/to/file
  ### 2- change character encoding: iconv -f original_charset -t utf-8 originalfile > newfile
  desc 'Import countries from csv file [usage: FILE=[path/to/file] rake import:countries'
  task :countries => :environment do
    TMP_TABLE = 'countries_import'
    if !ENV["FILE"] || !File.file?(Rails.root+ENV["FILE"]) #if the file is not defined, explain and leave.
      puts "Please specify a valid csv file from which to import countries data"
      puts "Usage: FILE=[path/to/file] rake import:countries"
      next
    end
    begin
      puts "Creating tmp table: #{TMP_TABLE}"
      ActiveRecord::Base.connection.execute "CREATE TABLE #{TMP_TABLE} ( legacy_id integer, iso2 varchar, iso3 varchar, name varchar, long_name varchar);"
      puts "Table created"
    rescue Exception => e
      puts "Tmp already exists removing data from tmp table before starting the import"
      ActiveRecord::Base.connection.execute "DELETE FROM #{TMP_TABLE};"
      puts "Data removed"
    end
    puts "Copying data from #{ENV["FILE"]} into tmp table"
    sql = <<-SQL
      COPY #{TMP_TABLE} ( legacy_id, iso2, iso3, name, long_name)
      FROM '#{Rails.root + ENV["FILE"]}'
      WITH DElIMITER ','
      CSV HEADER;
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "Data copied to tmp table"
    puts "There are #{Country.count} countries in the database."
    sql = <<-SQL
      INSERT INTO countries(iso_name, iso2_code, iso3_code, legacy_id, created_at, updated_at)
      SELECT DISTINCT INITCAP(BTRIM(TMP.name)), INITCAP(BTRIM(TMP.iso2)), INITCAP(BTRIM(TMP.iso3)), TMP.legacy_id, current_date, current_date
      FROM #{TMP_TABLE} AS TMP
      WHERE NOT EXISTS (
        SELECT * FROM countries
        WHERE legacy_id = TMP.legacy_id
      );
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "There are now #{Country.count} countries in the database"
  end


  namespace :countries do
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
