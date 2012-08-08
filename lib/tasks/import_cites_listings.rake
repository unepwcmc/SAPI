namespace :import do

  desc "Import CITES species listings from SQL Server [usage: rake import:cites_listings]"
  task :cites_listings => [:environment, "cites_listings:defaults"] do
    ANIMALS_QUERY = <<-SQL
      SELECT S.SpcRecID, L.LegListing, convert(varchar(10), L.LegDateListed, 120), C.CtyRecID, L.LegNotes
      FROM ORWELL.animals.dbo.species AS S INNER JOIN
        ORWELL.animals.dbo.legal AS L ON S.SpcRecID = L.LegSpcRecID INNER JOIN
        ORWELL.animals.dbo.legalname AS LN ON L.LegLnmRecID = LN.LnmRecID AND LN.LnmRecID = 3 INNER JOIN
        ORWELL.animals.dbo.Country as C ON L.LegISO2 = C.CtyISO2 -- OR L.LegISO2 IS NULL
      WHERE S.SpcRecID IN (#{TaxonConcept.where("data -> 'kingdom_name' = 'Animalia' AND legacy_id IS NOT NULL").map(&:legacy_id).join(',')});
    SQL

    PLANTS_QUERY = <<-SQL
      SELECT S.SpcRecID, L.LegListing, convert(varchar(10), L.LegDateListed, 120), C.CtyRecID, L.LegNotes
      FROM ORWELL.plants.dbo.species AS S INNER JOIN
        ORWELL.plants.dbo.legal AS L ON S.SpcRecID = L.LegSpcRecID AND L.LegListing IN ('I', 'II', 'III', 'I/II') INNER JOIN
        ORWELL.plants.dbo.legalname AS LN ON L.LegLnmRecID = LN.LnmRecID AND LN.LnmRecID = 3 INNER JOIN
        ORWELL.animals.dbo.Country as C ON L.LegISO2 = C.CtyISO2 -- OR L.LegISO2 IS NULL
      WHERE S.SpcRecID IN (#{TaxonConcept.where("data -> 'kingdom_name' = 'Plantae' AND legacy_id IS NOT NULL").map(&:legacy_id).join(',')});
    SQL
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
    ["animals", "plants"].each do |t|
      drop_table(TMP_TABLE)
      create_table(TMP_TABLE)
      query = "#{t.upcase}_QUERY".constantize
      copy_data(TMP_TABLE, query)
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
            WHEN (BTRIM(TMP.country_legacy_id) IS NULL OR BTRIM(TMP.country_legacy_id) = '') THEN NULL
            ELSE TMP.country_legacy_id::INTEGER
          END;
        COMMIT;
      SQL
      ActiveRecord::Base.connection.execute(sql)
      puts "#{ListingChange.count - listings_count} CITES listings were added to the database"
      puts "#{ListingDistribution.count - listings_d_count} listing distributions were added to the database"
    end
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
