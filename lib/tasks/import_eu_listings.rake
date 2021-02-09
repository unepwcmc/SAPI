namespace :import do

  desc "Import EU species listings from csv file (usage: rake import:eu_listings[path/to/file,path/to/another])"
  task :eu_listings, 10.times.map { |i| "file_#{i}".to_sym } => [:environment, "eu_listings:defaults"] do |t, args|
    TMP_TABLE = 'eu_listings_import'
    designation = Designation.find_by_name(Designation::EU)
    taxonomy = Taxonomy.find_by_name(Taxonomy::CITES_EU)
    puts "There are #{ListingChange.joins(:species_listing).
      where(:species_listings => { :designation_id => designation.id }).count} EU listings in the database"
    puts "There are #{ListingDistribution.joins(:listing_change => :species_listing).
      where(:species_listings => { :designation_id => designation.id }).count} EU listing distributions in the database"
    annex_A = SpeciesListing.find_by_designation_id_and_abbreviation(designation.id, 'A')
    annex_B = SpeciesListing.find_by_designation_id_and_abbreviation(designation.id, 'B')
    annex_C = SpeciesListing.find_by_designation_id_and_abbreviation(designation.id, 'C')
    annex_D = SpeciesListing.find_by_designation_id_and_abbreviation(designation.id, 'D')
    a = ChangeType.find_by_name_and_designation_id(ChangeType::ADDITION, designation.id)
    d = ChangeType.find_by_name_and_designation_id(ChangeType::DELETION, designation.id)
    e = ChangeType.find_by_name_and_designation_id(ChangeType::EXCEPTION, designation.id)
    english = Language.find_by_name_en('English')
    listings_count = ListingChange.joins(:species_listing).
      where(:species_listings => { :designation_id => designation.id }).count
    listings_d_count = ListingDistribution.joins(:listing_change => :species_listing).
      where(:species_listings => { :designation_id => designation.id }).count

    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)

      kingdom = file.split('/').last.split('_')[0].titleize

      puts "CREATING temporary column and view"
      ActiveRecord::Base.connection.execute(<<-SQL
        CREATE VIEW #{TMP_TABLE}_view AS
        SELECT ROW_NUMBER() OVER () AS row_id, * FROM #{TMP_TABLE}
        ORDER BY legacy_id, listing_date, annex, country_iso2
      SQL
      )
      ActiveRecord::Base.connection.execute("ALTER TABLE listing_changes DROP COLUMN IF EXISTS import_row_id")
      ActiveRecord::Base.connection.execute("ALTER TABLE listing_changes ADD COLUMN import_row_id integer")
      ActiveRecord::Base.connection.execute("ALTER TABLE annotations DROP COLUMN IF EXISTS import_row_id")
      ActiveRecord::Base.connection.execute("ALTER TABLE annotations ADD COLUMN import_row_id integer")

      copy_data(file, TMP_TABLE)

      sql = <<-SQL
          WITH new_annotations AS (
            INSERT INTO annotations(
              import_row_id,
              full_note_en, created_at, updated_at
            )
            SELECT DISTINCT TMP.row_id,
               TMP.full_note_en, current_date, current_date
            FROM #{TMP_TABLE}_view AS TMP
            WHERE TMP.full_note_en IS NOT NULL AND TMP.full_note_en <> 'NULL'
            RETURNING import_row_id, id
          )
          INSERT INTO listing_changes(
            import_row_id,
            taxon_concept_id, species_listing_id, change_type_id,
            annotation_id, hash_annotation_id, effective_at, is_current,
            explicit_change, inclusion_taxon_concept_id, created_at, updated_at,
            event_id
          )
          SELECT row_id,
            taxon_concepts.id,
            CASE
              WHEN UPPER(BTRIM(TMP.annex)) like '%A' THEN #{annex_A.id}
              WHEN UPPER(BTRIM(TMP.annex)) like '%B' THEN #{annex_B.id}
              WHEN UPPER(BTRIM(TMP.annex)) like '%C' THEN #{annex_C.id}
              WHEN UPPER(BTRIM(TMP.annex)) like '%D' THEN #{annex_D.id}
              ELSE NULL
            END,
            CASE
              WHEN TMP.annex ilike 'DEL%' THEN #{d.id}
              ELSE #{a.id}
            END,
            new_annotations.id,
            hash_annotations.id,
            TMP.listing_date,
            CASE
              WHEN TMP.is_current IS NULL THEN 'f'
              ELSE TMP.is_current
            END,
            't'::BOOLEAN,
            inclusion_taxon_concepts.id,
            current_date, current_date, events2.id
          FROM #{TMP_TABLE}_view AS TMP
          INNER JOIN ranks
          ON LOWER(ranks.name) = LOWER(TMP.rank)
          LEFT JOIN ranks inclusion_ranks
          ON LOWER(inclusion_ranks.name) = LOWER(rank_for_inclusions)
          INNER JOIN taxon_concepts
          ON taxon_concepts.legacy_id = TMP.legacy_id
          AND taxon_concepts.legacy_type = '#{kingdom}'
          AND taxon_concepts.rank_id = ranks.id
          AND taxon_concepts.taxonomy_id = #{taxonomy.id}
          LEFT JOIN taxon_concepts inclusion_taxon_concepts
          ON inclusion_taxon_concepts.legacy_id = TMP.included_in_rec_id
          AND inclusion_taxon_concepts.legacy_type = '#{kingdom}'
          AND inclusion_taxon_concepts.rank_id = inclusion_ranks.id
          AND inclusion_taxon_concepts.taxonomy_id = #{taxonomy.id}
          LEFT JOIN new_annotations ON new_annotations.import_row_id = TMP.row_id
          LEFT JOIN annotations AS hash_annotations
            ON UPPER(hash_annotations.symbol || ' ' || hash_annotations.parent_symbol) = BTRIM(UPPER(TMP.hash_note))
          LEFT JOIN events ON events.id = hash_annotations.event_id AND events.designation_id = #{designation.id}
          LEFT JOIN events AS events2 ON events2.legacy_id = TMP.event_legacy_id AND events2.designation_id = #{designation.id};
      SQL

      puts "INSERTING listing_changes"
      ActiveRecord::Base.connection.execute(sql)

      # add taxonomic exceptions
      sql = <<-SQL
      INSERT INTO listing_changes (parent_id, taxon_concept_id, species_listing_id, change_type_id, effective_at, is_current, created_at, updated_at)
      SELECT * FROM (
        WITH eu_listings_import_per_taxon_exclusion AS (
          SELECT row_id,
          split_part(regexp_split_to_table(excluded_taxa,','),':',1) AS exclusion_rank,
          split_part(regexp_split_to_table(excluded_taxa,','),':',2) AS exclusion_legacy_id
          FROM eu_listings_import_view
          WHERE excluded_taxa IS NOT NULL
        )
        SELECT
        --eu_listings_import_per_taxon_exclusion.*,
        --exclusion_ranks.name,
        listing_changes.id,
        exclusion_taxon_concepts.id AS exclusion_id,
        listing_changes.species_listing_id,
        #{e.id},
        effective_at,
        false AS is_current,
        NOW(), NOW()
        FROM eu_listings_import_per_taxon_exclusion
        INNER JOIN ranks exclusion_ranks
          ON BTRIM(LOWER(exclusion_ranks.name)) = BTRIM(LOWER(exclusion_rank))
        INNER JOIN taxon_concepts exclusion_taxon_concepts
          ON exclusion_taxon_concepts.legacy_id = exclusion_legacy_id::INTEGER
          AND exclusion_taxon_concepts.legacy_type = '#{kingdom}'
          AND exclusion_taxon_concepts.rank_id = exclusion_ranks.id
          AND exclusion_taxon_concepts.taxonomy_id = #{taxonomy.id}
        INNER JOIN listing_changes
          ON row_id = import_row_id
      ) q
      SQL

      puts "INSERTING taxonomic exceptions"
      ActiveRecord::Base.connection.execute(sql)

      # add population exceptions
      sql = <<-SQL
      WITH exceptions AS (
              -- first insert the exception records -- there's just one / listing change
              INSERT INTO listing_changes (parent_id, taxon_concept_id, species_listing_id, change_type_id, effective_at, is_current, created_at, updated_at)
              SELECT
              listing_changes.id,
              listing_changes.taxon_concept_id,
              listing_changes.species_listing_id,
              #{e.id},
              effective_at,
              false AS is_current,
              NOW(), NOW()
              FROM eu_listings_import_view
              INNER JOIN listing_changes
                ON row_id = import_row_id
              WHERE excluded_populations_iso2 IS NOT NULL
              RETURNING id, parent_id
      ),
      excluded_populations AS (
      SELECT exceptions.*, split_part(regexp_split_to_table(excluded_populations_iso2,','),':',1) AS iso_code2
      FROM exceptions
      INNER JOIN listing_changes ON exceptions.parent_id = listing_changes.id
      INNER JOIN eu_listings_import_view ON eu_listings_import_view.row_id = listing_changes.import_row_id
      )
      INSERT INTO listing_distributions (listing_change_id, geo_entity_id, is_party, created_at, updated_at)
      SELECT excluded_populations.id, geo_entities.id, 'f', NOW(), NOW()
      FROM excluded_populations
      INNER JOIN geo_entities ON UPPER(geo_entities.iso_code2) = UPPER(BTRIM(excluded_populations.iso_code2)) AND geo_entities.is_current = 't'
      SQL

      puts "INSERTING population exceptions (listing distributions)"
      ActiveRecord::Base.connection.execute(sql)

      sql = <<-SQL
      WITH listed_populations AS (
        SELECT listing_changes.id, split_part(regexp_split_to_table(populations_iso2,','),':',1) AS iso_code2
        FROM eu_listings_import_view AS TMP
        INNER JOIN listing_changes ON TMP.row_id = listing_changes.import_row_id
      )
      INSERT INTO listing_distributions (listing_change_id, geo_entity_id, is_party, created_at, updated_at)
      SELECT listed_populations.id, geo_entities.id, 'f', NOW(), NOW()
      FROM listed_populations
      INNER JOIN geo_entities ON UPPER(geo_entities.iso_code2) = UPPER(BTRIM(listed_populations.iso_code2)) AND geo_entities.is_current = 't'
      SQL

      puts "INSERTING listed populations (listing distributions)"
      ActiveRecord::Base.connection.execute(sql)

      sql = <<-SQL
          INSERT INTO listing_distributions(listing_change_id, geo_entity_id, is_party, created_at, updated_at)
          SELECT DISTINCT listing_changes.id, geo_entities.id, 't'::BOOLEAN, current_date, current_date
          FROM #{TMP_TABLE}_view AS TMP
          INNER JOIN geo_entities ON UPPER(geo_entities.iso_code2) like UPPER(BTRIM(TMP.country_iso2))
          INNER JOIN listing_changes ON TMP.row_id = listing_changes.import_row_id
          WHERE TMP.country_iso2 <> 'Null' AND TMP.country_iso2 IS NOT NULL AND geo_entities.is_current = 't'
      SQL
      puts "INSERTING parties (listing distributions)"
      ActiveRecord::Base.connection.execute(sql)

    end

    puts "DROPPING temporary column and view"
    ActiveRecord::Base.connection.execute("ALTER TABLE listing_changes DROP COLUMN import_row_id")
    ActiveRecord::Base.connection.execute("ALTER TABLE annotations DROP COLUMN import_row_id")
    ActiveRecord::Base.connection.execute("DROP VIEW eu_listings_import_view")

    new_listings_count = ListingChange.joins(:species_listing).
      where(:species_listings => { :designation_id => designation.id }).count
    new_listings_d_count = ListingDistribution.joins(:listing_change => :species_listing).
      where(:species_listings => { :designation_id => designation.id }).count
    puts "#{new_listings_count - listings_count} EU listings were added to the database"
    puts "#{new_listings_d_count - listings_d_count} EU listing distributions were added to the database"

  end

  namespace :eu_listings do
    desc 'Add defaults EU listings and default ChangeTypes'
    task :defaults => :environment do
      puts 'Going to create EU default species listings, if they do not exist'
      designation = Designation.find_by_name("EU")
      ["A", "B", "C", "D"].each do |annex|
        SpeciesListing.find_or_create_by(name: "Annex #{annex}", abbreviation: annex, designation_id: designation.id)
      end
      puts 'Going to create change types defaults, if they dont already exist'
      ChangeType.dict.each do |c_type|
        ChangeType.find_or_create_by(name: c_type, designation_id: designation.id)
      end
      puts 'Created appendices and change type defaults'
    end
    desc "Drop EU species listings"
    task :delete_all => :environment do
      designation = Designation.find_by_name("EU")
      Annotation.joins(:event).
        where(:events => { :designation_id => designation.id }).delete_all
      ListingDistribution.joins(:listing_change).
        where(:listing_changes => { :desigantion_id => designation.id }).delete_all
      ListingChange.where(:designation_id => designation.id).delete_all
    end
  end
end
