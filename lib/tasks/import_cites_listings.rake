namespace :import do

  desc "Import CITES species listings from csv file [usage: FILE=[path/to/file] rake import:cites_listings"
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
          INNER JOIN taxon_concepts ON taxon_concepts.legacy_id = TMP.spc_rec_id;
  
          INSERT INTO listing_distributions(listing_change_id, geo_entity_id, is_party, created_at, updated_at)
          SELECT DISTINCT listing_changes.id, geo_entities.id, 't'::BOOLEAN, current_date, current_date
          FROM #{TMP_TABLE} AS TMP
          INNER JOIN listing_changes ON
            listing_changes.species_listing_id = CASE
                  WHEN UPPER(BTRIM(TMP.appendix)) like 'III%' THEN #{appendix_3.id}
                  WHEN UPPER(BTRIM(TMP.appendix)) like 'II%' THEN #{appendix_2.id}
                  WHEN UPPER(BTRIM(TMP.appendix)) like 'I%' THEN #{appendix_1.id}
                  ELSE NULL
                END AND
            listing_changes.change_type_id = CASE
                  WHEN TMP.appendix like '%/r' THEN #{r.id}
                  WHEN TMP.appendix like '%/w' THEN #{rw.id}
                  WHEN TMP.appendix ilike '%DELETED%' THEN #{d.id}
                  ELSE #{a.id}
                END AND
            listing_changes.effective_at = TMP.listing_date
          INNER JOIN taxon_concepts ON taxon_concepts.id = listing_changes.taxon_concept_id AND taxon_concepts.legacy_id = TMP.spc_rec_id
          INNER JOIN geo_entities ON geo_entities.legacy_id = CASE
            WHEN TMP.country_legacy_id = 'NULL' THEN NULL
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
