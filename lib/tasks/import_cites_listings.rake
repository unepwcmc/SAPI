namespace :import do

  desc "Import CITES species listings from csv file (usage: rake import:cites_listings[path/to/file,path/to/another])"
  task :cites_listings, 10.times.map { |i| "file_#{i}".to_sym } => [:environment, "cites_listings:defaults"] do |t, args|
    TMP_TABLE = 'cites_listings_import'
    designation = Designation.find_by_name(Designation::CITES)
    appendix_1 = SpeciesListing.find_by_designation_id_and_abbreviation(designation.id, 'I')
    appendix_2 = SpeciesListing.find_by_designation_id_and_abbreviation(designation.id, 'II')
    appendix_3 = SpeciesListing.find_by_designation_id_and_abbreviation(designation.id, 'III')
    a = ChangeType.find_by_name(ChangeType::ADDITION)
    d = ChangeType.find_by_name(ChangeType::DELETION)
    r = ChangeType.find_by_name(ChangeType::RESERVATION)
    rw = ChangeType.find_by_name(ChangeType::RESERVATION_WITHDRAWAL)
    english = Language.find_by_name('English')
    listings_count = ListingChange.count
    listings_d_count = ListingDistribution.count
    annotations_count = Annotation.count

    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      puts "CREATING temporary columns and view"
      ActiveRecord::Base.connection.execute(<<-SQL
        CREATE VIEW #{TMP_TABLE}_view AS
        SELECT ROW_NUMBER() OVER () AS row_id, * FROM #{TMP_TABLE}
      SQL
      )
      ActiveRecord::Base.connection.execute("ALTER TABLE listing_changes DROP COLUMN IF EXISTS import_row_id")
      ActiveRecord::Base.connection.execute("ALTER TABLE listing_changes ADD COLUMN import_row_id integer")

      copy_data(file, TMP_TABLE)

      sql = <<-SQL
          INSERT INTO listing_changes(import_row_id, species_listing_id, taxon_concept_id, change_type_id, notes, created_at, updated_at, effective_at)
          SELECT row_id,
            CASE
              WHEN UPPER(BTRIM(TMP.appendix)) like 'III%' THEN #{appendix_3.id}
              WHEN UPPER(BTRIM(TMP.appendix)) like 'II%' THEN #{appendix_2.id}
              WHEN UPPER(BTRIM(TMP.appendix)) like 'I%' THEN #{appendix_1.id}
              ELSE NULL
            END, taxon_concepts.id,
            CASE
              WHEN TMP.appendix like '%/r' THEN #{r.id}
              WHEN TMP.appendix like '%/w' THEN #{rw.id}
              WHEN TMP.appendix ilike '%DELETED%' THEN #{d.id}
              ELSE #{a.id}
            END, notes, current_date, current_date, TMP.listing_date
          FROM #{TMP_TABLE}_view AS TMP
          INNER JOIN taxon_concepts ON taxon_concepts.legacy_id = TMP.spc_rec_id AND taxon_concepts.legacy_type = TMP.legacy_type;
      SQL
      puts "INSERTING listing_changes"
      ActiveRecord::Base.connection.execute(sql)

      sql = <<-SQL
          INSERT INTO listing_distributions(listing_change_id, geo_entity_id, is_party, created_at, updated_at)
          SELECT DISTINCT listing_changes.id, geo_entities.id, 't'::BOOLEAN, current_date, current_date
          FROM #{TMP_TABLE}_view AS TMP
          INNER JOIN geo_entities ON geo_entities.legacy_id = CASE
            WHEN BTRIM(TMP.country_legacy_id) = 'NULL' THEN NULL
            ELSE TMP.country_legacy_id::INTEGER
          END
          INNER JOIN listing_changes ON TMP.row_id = listing_changes.import_row_id
      SQL
      puts "INSERTING listing distributions"
      ActiveRecord::Base.connection.execute(sql)

      sql = <<-SQL
          WITH t AS (
            INSERT INTO annotations(listing_change_id, created_at, updated_at)
            SELECT DISTINCT listing_changes.id, current_date, current_date
            FROM #{TMP_TABLE}_view AS TMP
            INNER JOIN listing_changes ON TMP.row_id = listing_changes.import_row_id
            WHERE TMP.notes IS NOT NULL AND TMP.notes <> 'NULL'
            RETURNING *
          )
          INSERT INTO annotation_translations(annotation_id, language_id, full_note, created_at, updated_at)
          SELECT t.id, #{english.id}, TMP.notes, current_date, current_date
          FROM t
          INNER JOIN listing_changes ON t.listing_change_id = listing_changes.id
          INNER JOIN #{TMP_TABLE}_view AS TMP ON listing_changes.import_row_id = TMP.row_id
      SQL
      puts "INSERTING annotations"
      ActiveRecord::Base.connection.execute(sql)
    end

    puts "DROPPING temporary column and view"
    ActiveRecord::Base.connection.execute("ALTER TABLE listing_changes DROP COLUMN import_row_id")
    ActiveRecord::Base.connection.execute("DROP VIEW cites_listings_import_view")

    puts "#{ListingChange.count - listings_count} CITES listings were added to the database"
    puts "#{ListingDistribution.count - listings_d_count} listing distributions were added to the database"
    puts "#{Annotation.count - annotations_count} CITES annotations were added to the database"
  end

  namespace :cites_listings do
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
