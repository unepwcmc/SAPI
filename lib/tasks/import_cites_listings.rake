namespace :import do

  desc "Import CITES species listings from csv file [usage: FILE=[path/to/file] rake import:cites_listings"
  task :cites_listings => [:environment, "cites_listings:defaults", "cites_listings:copy_data"] do
    TMP_TABLE = 'cites_listings_import'
    designation = Designation.find_by_name(Designation::CITES)
    appendix_1 = SpeciesListing.find_by_designation_id_and_abbreviation(designation.id, 'I')
    appendix_2 = SpeciesListing.find_by_designation_id_and_abbreviation(designation.id, 'II')
    appendix_3 = SpeciesListing.find_by_designation_id_and_abbreviation(designation.id, 'III')
    a = ChangeType.find_by_name(ChangeType::ADDITION)
    d = ChangeType.find_by_name(ChangeType::DELETION)
    r = ChangeType.find_by_name(ChangeType::RESERVATION)
    rw = ChangeType.find_by_name(ChangeType::RESERVATION_WITHDRAWAL)
    listings_count = ListingChange.count
    listings_d_count = ListingDistribution.count
    sql = <<-SQL
      BEGIN;
        INSERT INTO listing_changes(species_listing_id, taxon_concept_id, change_type_id, created_at, updated_at, effective_at)
        SELECT DISTINCT
          CASE
            WHEN INITCAP(BTRIM(TMP.appendix)) like 'III%' THEN #{appendix_3.id}
            WHEN INITCAP(BTRIM(TMP.appendix)) like 'II%' THEN #{appendix_2.id}
            WHEN INITCAP(BTRIM(TMP.appendix)) like 'I%' THEN #{appendix_1.id}
            ELSE NULL
          END, taxon_concepts.id,
          CASE
            WHEN INITCAP(BTRIM(TMP.appendix)) like '%/r' THEN #{r.id}
            WHEN INITCAP(BTRIM(TMP.appendix)) like '%/w' THEN #{rw.id}
            WHEN INITCAP(BTRIM(TMP.appendix))  ilike '%DELETED%' THEN #{d.id}
            ELSE #{a.id}
          END, current_date, current_date, TMP.listing_date
        FROM #{TMP_TABLE} AS TMP
        INNER JOIN taxon_concepts ON taxon_concepts.legacy_id = TMP.spc_rec_id;

        INSERT INTO listing_distributions(listing_change_id, geo_entity_id, created_at, updated_at)
        SELECT DISTINCT listing_changes.id, geo_entities.id, current_date, current_date
        FROM #{TMP_TABLE} AS TMP
        INNER JOIN listing_changes ON
          listing_changes.species_listing_id = CASE
                WHEN INITCAP(BTRIM(TMP.appendix)) like 'III%' THEN #{appendix_3.id}
                WHEN INITCAP(BTRIM(TMP.appendix)) like 'II%' THEN #{appendix_2.id}
                WHEN INITCAP(BTRIM(TMP.appendix)) like 'I%' THEN #{appendix_1.id}
                ELSE NULL
              END AND
          listing_changes.change_type_id = CASE
                WHEN INITCAP(BTRIM(TMP.appendix)) like '%/r' THEN #{r.id}
                WHEN INITCAP(BTRIM(TMP.appendix)) like '%/w' THEN #{rw.id}
                WHEN INITCAP(BTRIM(TMP.appendix))  ilike '%DELETED%' THEN #{d.id}
                ELSE #{a.id}
              END AND
          listing_changes.effective_at = TMP.listing_date
        INNER JOIN taxon_concepts ON taxon_concepts.id = listing_changes.taxon_concept_id AND taxon_concepts.legacy_id = TMP.spc_rec_id
        INNER JOIN geo_entities ON geo_entities.legacy_id = cast(TMP.country_legacy_id as integer)
        WHERE TMP.country_legacy_id <> ' NULL';
      COMMIT;
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "#{ListingChange.count - listings_count} CITES listings were added to the database"
    puts "#{ListingDistribution.count - listings_d_count} listing distributions were added to the database"
  end

  namespace :cites_listings do
    desc 'Creates cites_listings_import table'
    task :create_table => :environment do
      TMP_TABLE = 'cites_listings_import'
      begin
        puts "Creating tmp table: #{TMP_TABLE}"
        ActiveRecord::Base.connection.execute "CREATE TABLE #{TMP_TABLE} ( spc_rec_id integer, appendix varchar, listing_date date, country_legacy_id varchar, notes varchar );"
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
      file = ENV["FILE"] || 'lib/assets/files/animals_complex_CITES_listings.csv'
      if !file || !File.file?(Rails.root+file) #if the file is not defined, explain and leave.
        puts "Please specify a valid csv file from which to import cites_listings data"
        puts "Usage: FILE=[path/to/file] rake import:cites_listings"
        next
      end
      puts "Copying data from #{file} into tmp table #{TMP_TABLE}"
      psql = <<-PSQL
\\COPY #{TMP_TABLE} (spc_rec_id, appendix, listing_date, country_legacy_id, notes)
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
