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
    listings_count = ListingChange.count
    listings_d_count = ListingDistribution.count

    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      ActiveRecord::Base.connection.execute("ALTER TABLE #{TMP_TABLE} ADD COLUMN listing_change_id integer")
      copy_data(file, TMP_TABLE)
      sql = <<-SQL
        BEGIN;
          INSERT INTO listing_changes(species_listing_id, taxon_concept_id, change_type_id, notes, created_at, updated_at, effective_at)
          SELECT DISTINCT
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
          FROM #{TMP_TABLE} AS TMP
          INNER JOIN taxon_concepts ON taxon_concepts.legacy_id = TMP.spc_rec_id AND taxon_concepts.legacy_type = TMP.legacy_type;

          WITH tt AS (
                  WITH t AS (
                    SELECT 
                      TMP.appendix AS appendix,
                      CASE
                              WHEN UPPER(BTRIM(TMP.appendix)) like 'III%' THEN #{appendix_3.id}
                              WHEN UPPER(BTRIM(TMP.appendix)) like 'II%' THEN #{appendix_2.id}
                              WHEN UPPER(BTRIM(TMP.appendix)) like 'I%' THEN #{appendix_1.id}
                        ELSE NULL
                      END AS species_listing_id, taxon_concepts.id AS taxon_concept_id,
                      CASE
                              WHEN TMP.appendix like '%/r' THEN #{r.id}
                              WHEN TMP.appendix like '%/w' THEN #{rw.id}
                              WHEN TMP.appendix ilike '%DELETED%' THEN #{d.id}
                              ELSE #{a.id}
                      END AS change_type_id, TMP.listing_date,
                      taxon_concepts.legacy_id,
                      taxon_concepts.legacy_type
                    FROM #{TMP_TABLE} AS TMP
                    INNER JOIN taxon_concepts ON taxon_concepts.legacy_id = TMP.spc_rec_id AND taxon_concepts.legacy_type = TMP.legacy_type
                  )
                  SELECT appendix, listing_date, legacy_id, legacy_type, listing_changes.id AS listing_change_id FROM t
                  INNER JOIN listing_changes ON 
                    t.taxon_concept_id = listing_changes.taxon_concept_id AND
                    t.species_listing_id = listing_changes.species_listing_id AND
                    t.change_type_id = listing_changes.change_type_id
          )
          UPDATE #{TMP_TABLE}
          SET listing_change_id = tt.listing_change_id
          FROM tt
          WHERE #{TMP_TABLE}.legacy_type = tt.legacy_type
          AND #{TMP_TABLE}.spc_rec_id = tt.legacy_id 
          AND #{TMP_TABLE}.appendix = tt.appendix
          AND #{TMP_TABLE}.listing_date = tt.listing_date;

          INSERT INTO listing_distributions(listing_change_id, geo_entity_id, is_party, created_at, updated_at)
          SELECT DISTINCT listing_change_id, geo_entities.id, 't'::BOOLEAN, current_date, current_date
          FROM #{TMP_TABLE} AS TMP
          INNER JOIN geo_entities ON geo_entities.legacy_id = CASE
            WHEN BTRIM(TMP.country_legacy_id) = 'NULL' THEN NULL
            ELSE TMP.country_legacy_id::INTEGER
          END;
        COMMIT;
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end
    puts "#{ListingChange.count - listings_count} CITES listings were added to the database"
    puts "#{ListingDistribution.count - listings_d_count} listing distributions were added to the database"
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
