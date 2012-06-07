namespace :import do

  desc "Import CITES species listings from csv file [usage: FILE=[path/to/file] rake import:cites_listings"
  task :cites_listings => [:environment, "cites_listings:defaults", "cites_listings:copy_data"] do
    TMP_TABLE = 'cites_listings_import'
    change_type = ChangeType.find_by_name(ChangeType::ADDITION)
    designation = Designation.find_by_name("CITES")
    listings_count = ListingChange.count
    sql = <<-SQL
      INSERT INTO listing_changes(species_listing_id, taxon_concept_id, change_type_id, created_at, updated_at)
      SELECT DISTINCT species_listings.id, taxon_concepts.id,  #{change_type.id}, current_date, current_date
      FROM #{TMP_TABLE} AS TMP
      INNER JOIN taxon_concepts ON taxon_concepts.legacy_id = TMP.spc_rec_id
      INNER JOIN species_listings ON INITCAP(BTRIM(species_listings.abbreviation)) = INITCAP(BTRIM(TMP.appendix)) AND species_listings.designation_id = #{designation.id}
      WHERE NOT EXISTS (
        SELECT * from listing_changes
        WHERE species_listing_id = species_listings.id AND taxon_concept_id = taxon_concepts.id AND change_type_id = #{change_type.id}
      );
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "#{ListingChange.count - listings_count} CITES listings were added to the database"
  end

  namespace :cites_listings do
    desc 'Creates cites_listings_import table'
    task :create_table => :environment do
      TMP_TABLE = 'cites_listings_import'
      begin
        puts "Creating tmp table: #{TMP_TABLE}"
        ActiveRecord::Base.connection.execute "CREATE TABLE #{TMP_TABLE} ( spc_rec_id integer, appendix varchar);"
        puts "Table created"
      rescue Exception => e
        puts "Tmp already exists removing data from tmp table before starting the import"
        ActiveRecord::Base.connection.execute "DELETE FROM #{TMP_TABLE};"
        puts "Data removed"
      end
    end

    desc 'Copy data into cites_listings_import table'
    task :copy_data => :create_table do
      TMP_TABLE = 'cites_listings_import'
      file = ENV["FILE"] || 'lib/assets/files/animals_CITES_listings.csv'
      if !file || !File.file?(Rails.root+file) #if the file is not defined, explain and leave.
        puts "Please specify a valid csv file from which to import cites_listings data"
        puts "Usage: FILE=[path/to/file] rake import:cites_listings"
        next
      end
      puts "Copying data from #{file} into tmp table #{TMP_TABLE}"
      psql = <<-PSQL
\\COPY #{TMP_TABLE} (spc_rec_id, appendix)
          FROM '#{Rails.root + file}'
          WITH DElIMITER ','
          CSV HEADER
      PSQL
      db_conf = YAML.load(File.open(Rails.root + "config/database.yml"))[Rails.env]
      system("export PGPASSWORD=#{db_conf["password"]} && psql -h #{db_conf["host"] || "localhost"} -U#{db_conf["username"]} -c \"#{psql}\" #{db_conf["database"]}")
      puts "Data copied to tmp table"
    end

    desc 'Removes cites_listings_import table'
    task :remove_table => :environment do
      TMP_TABLE = 'cites_listings_import'
      begin
        ActiveRecord::Base.connection.execute "DROP TABLE #{TMP_TABLE};"
        puts "Table removed"
      rescue Exception => e
        puts "Could not drop table #{TMP_TABLE}. It might not exist if this is the first time you are running this rake task."
      end
    end

    desc 'Add defaults CITES listings and default ChangeTypes'
    task :defaults => :environment do
      puts 'Going to create CITES default species listings, if they do not exist'
      designation = Designation.find_by_name("CITES")
      ["I", "II", "III"].each do |appendix|
        SpeciesListing.find_or_create_by_name_and_abbreviation_and_designation_id("Appendix #{appendix}", appendix, designation.id)
      end
      puts 'Going to create change types defaults, if they dont already exist'
      ChangeType.dict.each do |c_type|
        ChangeType.find_or_create_by_name(c_type)
      end
      puts 'Created appendices and change type defaults'
    end
  end
end
