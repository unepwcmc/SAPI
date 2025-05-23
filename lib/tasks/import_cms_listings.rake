namespace :import do
  desc 'Import CMS species listings from csv file (usage: rake import:cms_listings[path/to/file,path/to/another])'
  task :cms_listings, 10.times.map { |i| :"file_#{i}" } => [ :environment, 'cms_listings:defaults' ] do |t, args|
    import_helper = CsvImportHelper.new

    TMP_TABLE = 'cms_listings_import'
    designation = Designation.find_by(name: Designation::CMS)
    taxonomy = Taxonomy.find_by(name: Taxonomy::CMS)

    puts "There are #{ListingChange.joins(:species_listing).
      where(species_listings: { designation_id: designation.id }).count} CMS listings in the database"
    puts "There are #{ListingDistribution.joins(listing_change: :species_listing).
      where(species_listings: { designation_id: designation.id }).count} CMS listing distributions in the database"

    appendix_1 = SpeciesListing.find_by(designation_id: designation.id, abbreviation: 'I')
    appendix_2 = SpeciesListing.find_by(designation_id: designation.id, abbreviation: 'II')

    a = ChangeType.find_by(name: ChangeType::ADDITION, designation_id: designation.id)
    d = ChangeType.find_by(name: ChangeType::DELETION, designation_id: designation.id)
    e = ChangeType.find_by(name: ChangeType::EXCEPTION, designation_id: designation.id)

    english = Language.find_by(name_en: 'English')

    listings_count = ListingChange.joins(:species_listing).
      where(species_listings: { designation_id: designation.id }).count
    listings_d_count = ListingDistribution.joins(listing_change: :species_listing).
      where(species_listings: { designation_id: designation.id }).count

    files = import_helper.files_from_args(t, args)

    files.each do |file|
      import_helper.drop_table(TMP_TABLE)
      import_helper.create_table_from_csv_headers(file, TMP_TABLE)

      kingdom = 'Animalia'

      puts 'CREATING temporary column and view'

      ApplicationRecord.connection.execute(
        <<-SQL.squish
          CREATE VIEW #{TMP_TABLE}_view AS
          SELECT ROW_NUMBER() OVER () AS row_id, * FROM #{TMP_TABLE}
          WHERE #{TMP_TABLE}.appendix IN ('I', 'II')
          ORDER BY legacy_id, listing_date, appendix
        SQL
      )

      ApplicationRecord.connection.execute('ALTER TABLE listing_changes DROP COLUMN IF EXISTS import_row_id')
      ApplicationRecord.connection.execute('ALTER TABLE listing_changes ADD COLUMN import_row_id integer')
      ApplicationRecord.connection.execute('ALTER TABLE annotations DROP COLUMN IF EXISTS import_row_id')
      ApplicationRecord.connection.execute('ALTER TABLE annotations ADD COLUMN import_row_id integer')

      import_helper.copy_data(file, TMP_TABLE)

      sql = <<-SQL.squish
        WITH new_annotations AS (
          INSERT INTO annotations(
            import_row_id,
            full_note_en,
            created_at, updated_at
          )
          SELECT DISTINCT TMP.row_id,
            TMP.full_note_en,
            current_date, current_date
          FROM #{TMP_TABLE}_view AS TMP
          WHERE TMP.full_note_en IS NOT NULL AND TMP.full_note_en <> 'NULL'
          RETURNING import_row_id, id
        )
        INSERT INTO listing_changes(
          import_row_id,
          taxon_concept_id, species_listing_id, change_type_id,
          annotation_id, effective_at, is_current,
          explicit_change, inclusion_taxon_concept_id, created_at, updated_at
        )
        SELECT row_id,
          taxon_concepts.id,
          CASE
            WHEN (UPPER(TMP.appendix) = 'DELI' OR
              UPPER(TMP.appendix) = 'DELII') AND TMP.is_current = 't'::BOOLEAN THEN NULL
            WHEN UPPER(BTRIM(TMP.appendix)) like '%II%' THEN #{appendix_2.id}
            WHEN UPPER(BTRIM(TMP.appendix)) like '%I%' THEN #{appendix_1.id}
            ELSE NULL
          END,
          CASE
            WHEN TMP.appendix ilike 'DEL%' THEN #{d.id}
            ELSE #{a.id}
          END,
          new_annotations.id,
          to_date(TMP.listing_date, 'dd/mm/yyyy'),
          CASE
            WHEN TMP.is_current IS NULL THEN 'f'
            ELSE TMP.is_current
          END,
          CASE
            WHEN UPPER(TMP.appendix) LIKE 'DEL%'
            AND (TMP.is_current IS NULL OR TMP.is_current = 'f'::BOOLEAN)
            THEN FALSE
            ELSE TRUE
          END,
          inclusion_taxon_concepts.id,
          current_date, current_date
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
      SQL

      puts 'INSERTING listing_changes'
      ApplicationRecord.connection.execute(sql)

      # add taxonomic exceptions
      sql = <<-SQL.squish
        INSERT INTO listing_changes (parent_id, taxon_concept_id, species_listing_id, change_type_id, effective_at, is_current, created_at, updated_at)
        SELECT * FROM (
          WITH cms_listings_import_per_taxon_exclusion AS (
            SELECT row_id,
            split_part(regexp_split_to_table(excluded_taxa,','),':',1) AS exclusion_rank,
            split_part(regexp_split_to_table(excluded_taxa,','),':',2) AS exclusion_legacy_id
            FROM cms_listings_import_view
            WHERE excluded_taxa IS NOT NULL
          )
          SELECT
          listing_changes.id,
          exclusion_taxon_concepts.id AS exclusion_id,
          listing_changes.species_listing_id,
          #{e.id},
          effective_at,
          false AS is_current,
          NOW(), NOW()
          FROM cms_listings_import_per_taxon_exclusion
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

      puts 'INSERTING taxonomic exceptions'
      ApplicationRecord.connection.execute(sql)

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
          FROM cms_listings_import_view
          INNER JOIN listing_changes
            ON row_id = import_row_id
          WHERE excluded_populations_iso2 IS NOT NULL
          RETURNING id, parent_id
        ),
        excluded_populations AS (
        SELECT exceptions.*, split_part(regexp_split_to_table(excluded_populations_iso2,','),':',1) AS iso_code2
        FROM exceptions
        INNER JOIN listing_changes ON exceptions.parent_id = listing_changes.id
        INNER JOIN cms_listings_import_view ON cms_listings_import_view.row_id = listing_changes.import_row_id
        )
        INSERT INTO listing_distributions (listing_change_id, geo_entity_id, is_party, created_at, updated_at)
        SELECT excluded_populations.id, geo_entities.id, 'f', NOW(), NOW()
        FROM excluded_populations
        INNER JOIN geo_entities ON UPPER(geo_entities.iso_code2) = UPPER(BTRIM(excluded_populations.iso_code2)) AND geo_entities.is_current = 't'
      SQL

      puts 'INSERTING population exceptions (listing distributions)'
      ApplicationRecord.connection.execute(sql)

      sql = <<-SQL.squish
        WITH listed_populations AS (
          SELECT listing_changes.id, split_part(regexp_split_to_table(populations_iso2,','),':',1) AS iso_code2
          FROM cms_listings_import_view AS TMP
          INNER JOIN listing_changes ON TMP.row_id = listing_changes.import_row_id
        )
        INSERT INTO listing_distributions (listing_change_id, geo_entity_id, is_party, created_at, updated_at)
        SELECT listed_populations.id, geo_entities.id, 'f', NOW(), NOW()
        FROM listed_populations
        INNER JOIN geo_entities ON UPPER(geo_entities.iso_code2) = UPPER(BTRIM(listed_populations.iso_code2)) AND geo_entities.is_current = 't'
      SQL

      puts 'INSERTING listed populations (listing distributions)'
      ApplicationRecord.connection.execute(sql)

      sql = <<-SQL.squish
        INSERT INTO instruments(name, designation_id, created_at, updated_at)
        SELECT DISTINCT BTRIM(#{TMP_TABLE}.designation), #{designation.id},
          NOW(), NOW()
        FROM #{TMP_TABLE}
        WHERE BTRIM(#{TMP_TABLE}.designation) <> 'CMS' AND NOT EXISTS (
          SELECT * FROM instruments
          WHERE UPPER(name) = BTRIM(UPPER(#{TMP_TABLE}.designation))
        )
      SQL

      puts 'INSERTING CMS instruments'
      ApplicationRecord.connection.execute(sql)

      sql = <<-SQL.squish
        INSERT INTO taxon_instruments(taxon_concept_id, instrument_id, effective_from, created_at, updated_at)
        SELECT DISTINCT t.id, i.id, to_date(#{TMP_TABLE}.listing_date, 'dd/mm/yyyy'),
          NOW(), NOW()
        FROM #{TMP_TABLE}
        INNER JOIN taxon_concepts t ON t.legacy_id = #{TMP_TABLE}.legacy_id
          AND t.legacy_type = '#{kingdom}'
          AND t.taxonomy_id = #{taxonomy.id}
        INNER JOIN instruments i ON UPPER(i.name) = BTRIM(UPPER(#{TMP_TABLE}.designation))
        WHERE #{TMP_TABLE}.appendix NOT IN ('I', 'II') AND
          NOT EXISTS(
            SELECT * FROM taxon_instruments ti
            WHERE ti.taxon_concept_id = t.id
              AND ti.instrument_id = i.id
              AND effective_from = to_date(#{TMP_TABLE}.listing_date, 'yyyy')
          )
      SQL

      puts 'INSERTING taxon_instruments relationships'
      ApplicationRecord.connection.execute(sql)
    end

    puts 'DROPPING temporary column and view'
    #    ApplicationRecord.connection.execute("ALTER TABLE listing_changes DROP COLUMN import_row_id")
    #    ApplicationRecord.connection.execute("ALTER TABLE annotations DROP COLUMN import_row_id")
    #    ApplicationRecord.connection.execute("DROP VIEW cms_listings_import_view")

    new_listings_count = ListingChange.joins(:species_listing).
      where(species_listings: { designation_id: designation.id }).count

    new_listings_d_count = ListingDistribution.joins(listing_change: :species_listing).
      where(species_listings: { designation_id: designation.id }).count

    puts "#{new_listings_count - listings_count} CMS listings were added to the database"
    puts "#{new_listings_d_count - listings_d_count} CMS listing distributions were added to the database"
  end

  namespace :cms_listings do
    desc 'Add defaults CMS listings and default ChangeTypes'
    task defaults: :environment do
      puts 'Going to create CMS default species listings, if they do not exist'

      designation = Designation.find_by(name: 'CMS')

      [ 'I', 'II' ].each do |appendix|
        SpeciesListing.find_or_create_by(name: "Appendix #{appendix}", abbreviation: appendix, designation_id: designation.id)
      end

      puts 'Going to create change types defaults, if they dont already exist'

      ChangeType.dict.each do |c_type|
        ChangeType.find_or_create_by(name: c_type, designation_id: designation.id)
      end

      puts 'Created appendices and change type defaults'
    end

    desc 'Drop CMS species listings'
    task delete_all: :environment do
      designation = Designation.find_by(name: 'CMS')

      AnnotationTranslation.joins(annotation: :event).
        where(events: { designation_id: designation.id }).delete_all

      Annotation.joins(:event).
        where(events: { designation_id: designation.id }).delete_all

      ListingDistribution.joins(:listing_change).
        where(listing_changes: { desigantion_id: designation.id }).delete_all

      ListingChange.where(designation_id: designation.id).delete_all
    end
  end
end
