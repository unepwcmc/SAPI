namespace :import do

  desc "Import CITES species listings from csv file (usage: rake import:cites_listings[path/to/file,path/to/another])"
  task :cites_listings, 10.times.map { |i| "file_#{i}".to_sym } => [:environment, "cites_listings:defaults"] do |t, args|
    TMP_TABLE = 'cites_listings_import'
    puts "There are #{ListingChange.count} CITES listings in the database"
    puts "There are #{ListingDistribution.count} listing distributions in the database"
    designation = Designation.find_by_name(Designation::CITES)
    appendix_1 = SpeciesListing.find_by_designation_id_and_abbreviation(designation.id, 'I')
    appendix_2 = SpeciesListing.find_by_designation_id_and_abbreviation(designation.id, 'II')
    appendix_3 = SpeciesListing.find_by_designation_id_and_abbreviation(designation.id, 'III')
    a = ChangeType.find_by_name(ChangeType::ADDITION)
    d = ChangeType.find_by_name(ChangeType::DELETION)
    r = ChangeType.find_by_name(ChangeType::RESERVATION)
    rw = ChangeType.find_by_name(ChangeType::RESERVATION_WITHDRAWAL)
    english = Language.find_by_name_en('English')
    listings_count = ListingChange.count
    listings_d_count = ListingDistribution.count
    annotations_count = Annotation.count

    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      puts "CREATING temporary column and view"
      ActiveRecord::Base.connection.execute(<<-SQL
        CREATE VIEW #{TMP_TABLE}_view AS
        SELECT ROW_NUMBER() OVER () AS row_id, * FROM #{TMP_TABLE}
        ORDER BY legacy_id, listing_date, appendix, country_iso2
      SQL
      )
      ActiveRecord::Base.connection.execute("ALTER TABLE listing_changes DROP COLUMN IF EXISTS import_row_id")
      ActiveRecord::Base.connection.execute("ALTER TABLE listing_changes ADD COLUMN import_row_id integer")

      copy_data(file, TMP_TABLE)

      sql = <<-SQL
          INSERT INTO listing_changes(import_row_id, species_listing_id, taxon_concept_id, change_type_id, created_at, updated_at, effective_at, is_current, inclusion_taxon_concept_id)
          SELECT row_id,
            CASE
              WHEN UPPER(BTRIM(TMP.appendix)) like '%III%' THEN #{appendix_3.id}
              WHEN UPPER(BTRIM(TMP.appendix)) like '%II%' THEN #{appendix_2.id}
              WHEN UPPER(BTRIM(TMP.appendix)) like '%I%' THEN #{appendix_1.id}
              ELSE NULL
            END, taxon_concepts.id,
            CASE
              WHEN TMP.appendix like '%/r' THEN #{r.id}
              WHEN TMP.appendix like '%/w' THEN #{rw.id}
              WHEN TMP.appendix ilike 'DEL%' THEN #{d.id}
              ELSE #{a.id}
            END, current_date, current_date, TMP.listing_date,
            CASE
              WHEN TMP.is_current IS NULL THEN 'f'
              ELSE TMP.is_current
            END,
            inclusion_taxon_concepts.id
          FROM #{TMP_TABLE}_view AS TMP
          INNER JOIN ranks
          ON LOWER(ranks.name) = LOWER(TMP.rank)
          LEFT JOIN ranks inclusion_ranks
          ON LOWER(inclusion_ranks.name) = LOWER(rank_for_inclusions)
          INNER JOIN taxon_concepts
          ON taxon_concepts.legacy_id = TMP.legacy_id
          AND taxon_concepts.legacy_type = 'Animalia'
          AND taxon_concepts.rank_id = ranks.id
          LEFT JOIN taxon_concepts inclusion_taxon_concepts
          ON inclusion_taxon_concepts.legacy_id = TMP.included_in_rec_id
          AND inclusion_taxon_concepts.legacy_type = 'Animalia'
          AND inclusion_taxon_concepts.rank_id = inclusion_ranks.id;
      SQL

      puts "INSERTING listing_changes"
      ActiveRecord::Base.connection.execute(sql)

      #add taxonomic exceptions
      sql = <<-SQL
      INSERT INTO listing_changes (parent_id, taxon_concept_id, species_listing_id, change_type_id, effective_at, is_current, created_at, updated_at)
      SELECT * FROM (
        WITH cites_listings_import_per_taxon_exclusion AS (
          SELECT row_id, 
          split_part(regexp_split_to_table(excluded_taxa,','),':',1) AS exclusion_rank,
          split_part(regexp_split_to_table(excluded_taxa,','),':',2) AS exclusion_legacy_id
          FROM cites_listings_import_view
          WHERE excluded_taxa IS NOT NULL
        )
        SELECT
        --cites_listings_import_per_taxon_exclusion.*,
        --exclusion_ranks.name, 
        listing_changes.id, 
        exclusion_taxon_concepts.id AS exclusion_id,
        listing_changes.species_listing_id, 
        change_types.id,
        effective_at,
        false AS is_current,
        NOW(), NOW()
        FROM cites_listings_import_per_taxon_exclusion
        INNER JOIN ranks exclusion_ranks
          ON BTRIM(LOWER(exclusion_ranks.name)) = BTRIM(LOWER(exclusion_rank))
        INNER JOIN taxon_concepts exclusion_taxon_concepts
          ON exclusion_taxon_concepts.legacy_id = exclusion_legacy_id::INTEGER
          AND exclusion_taxon_concepts.legacy_type = 'Animalia'
          AND exclusion_taxon_concepts.rank_id = exclusion_ranks.id
        INNER JOIN listing_changes
          ON row_id = import_row_id
        INNER JOIN change_types ON change_types.name = 'EXCEPTION'
      ) q
      SQL

      puts "INSERTING taxonomic exceptions"
      ActiveRecord::Base.connection.execute(sql)

      #add population exceptions
      sql =<<-SQL
      WITH exceptions AS (
              -- first insert the exception records -- there's just one / listing change
              INSERT INTO listing_changes (parent_id, taxon_concept_id, species_listing_id, change_type_id, effective_at, is_current, created_at, updated_at)
              SELECT
              listing_changes.id, 
              listing_changes.taxon_concept_id,
              listing_changes.species_listing_id,
              change_types.id,
              effective_at,
              false AS is_current,
              NOW(), NOW()
              FROM cites_listings_import_view 
              INNER JOIN listing_changes
                ON row_id = import_row_id
              INNER JOIN change_types ON change_types.name = 'EXCEPTION'
              WHERE excluded_populations_iso2 IS NOT NULL
              RETURNING id, parent_id
      ),
      excluded_populations AS ( 
      SELECT exceptions.*, split_part(regexp_split_to_table(excluded_populations_iso2,','),':',1) AS iso_code2
      FROM exceptions
      INNER JOIN listing_changes ON exceptions.parent_id = listing_changes.id
      INNER JOIN cites_listings_import_view ON cites_listings_import_view.row_id = listing_changes.import_row_id
      )
      INSERT INTO listing_distributions (listing_change_id, geo_entity_id, is_party, created_at, updated_at)
      SELECT excluded_populations.id, geo_entities.id, 'f', NOW(), NOW() 
      FROM excluded_populations
      INNER JOIN geo_entities ON UPPER(geo_entities.iso_code2) = UPPER(excluded_populations.iso_code2)
      SQL

      puts "INSERTING population exceptions (listing distributions)"
      ActiveRecord::Base.connection.execute(sql)

      sql = <<-SQL
      WITH listed_populations AS (
        SELECT listing_changes.id, split_part(regexp_split_to_table(populations_iso2,','),':',1) AS iso_code2
        FROM cites_listings_import_view AS TMP
        INNER JOIN listing_changes ON TMP.row_id = listing_changes.import_row_id
      )
      INSERT INTO listing_distributions (listing_change_id, geo_entity_id, is_party, created_at, updated_at)
      SELECT listed_populations.id, geo_entities.id, 'f', NOW(), NOW()
      FROM listed_populations
      INNER JOIN geo_entities ON UPPER(geo_entities.iso_code2) = UPPER(listed_populations.iso_code2)
      SQL

      puts "INSERTING listed populations (listing distributions)"
      ActiveRecord::Base.connection.execute(sql)

      sql = <<-SQL
          INSERT INTO listing_distributions(listing_change_id, geo_entity_id, is_party, created_at, updated_at)
          SELECT DISTINCT listing_changes.id, geo_entities.id, 't'::BOOLEAN, current_date, current_date
          FROM #{TMP_TABLE}_view AS TMP
          INNER JOIN geo_entities ON geo_entities.iso_code2 like INITCAP(BTRIM(TMP.country_iso2))
          INNER JOIN listing_changes ON TMP.row_id = listing_changes.import_row_id
          WHERE TMP.country_iso2 <> 'Null' AND TMP.country_iso2 IS NOT NULL
      SQL
      puts "INSERTING parties (listing distributions)"
      ActiveRecord::Base.connection.execute(sql)

      sql = <<-SQL
          WITH t AS (
            INSERT INTO annotations(listing_change_id, created_at, updated_at)
            SELECT DISTINCT listing_changes.id, current_date, current_date
            FROM #{TMP_TABLE}_view AS TMP
            INNER JOIN listing_changes ON TMP.row_id = listing_changes.import_row_id
            WHERE TMP.short_note_en IS NOT NULL AND TMP.short_note_en <> 'NULL'
            RETURNING *
          )
          INSERT INTO annotation_translations(annotation_id, language_id, short_note, full_note, created_at, updated_at)
          SELECT t.id, #{english.id}, '',
            CASE
              WHEN TMP.full_note_en like 'NULL' OR TMP.full_note_en IS NULL THEN TMP.short_note_en
              ELSE TMP.full_note_en
            END
          , current_date, current_date
          FROM t
          INNER JOIN listing_changes ON t.listing_change_id = listing_changes.id
          INNER JOIN #{TMP_TABLE}_view AS TMP ON listing_changes.import_row_id = TMP.row_id
      SQL
      puts "INSERTING annotations"
      ActiveRecord::Base.connection.execute(sql)
    end

    puts "DROPPING temporary column and view"
    #TODO ActiveRecord::Base.connection.execute("ALTER TABLE listing_changes DROP COLUMN import_row_id")
    #TODO ActiveRecord::Base.connection.execute("DROP VIEW cites_listings_import_view")

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
    desc "Drop CITES species listings"
    task :delete_all => :environment do
      AnnotationTranslation.delete_all
      Annotation.delete_all
      ListingDistribution.delete_all
      ListingChange.delete_all
    end
  end
end
