require Rails.root.join('lib/tasks/helpers_for_import.rb')
namespace :import do

  desc "Import species records from csv files (usage: rake import:species[path/to/file,path/to/another])"
  task :species, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'species_import'
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      kingdom = file.split('/').last.split('_')[0].titleize

      #import_data_for Rank::KINGDOM
      import_data_for kingdom, Rank::PHYLUM
      import_data_for kingdom, Rank::CLASS
      import_data_for kingdom, Rank::ORDER
      import_data_for kingdom, Rank::FAMILY
      import_data_for kingdom, Rank::SUBFAMILY
      import_data_for kingdom, Rank::GENUS
      import_data_for kingdom, Rank::SPECIES
      import_data_for kingdom, Rank::SUBSPECIES
      if kingdom == 'Plantae'
        import_data_for kingdom, Rank::VARIETY
      end
    end
  end
end

# Copies data from the temporary table to the correct tables in the database
#
# @param [String] which the rank to be copied.
def import_data_for kingdom, rank, synonyms=nil
  puts "Importing #{rank}"
  rank_id = Rank.select(:id).where(:name => rank).first.id
  existing = TaxonConcept.where(:rank_id => rank_id).count
  puts "There were #{existing} #{rank} before we started"

  sql = <<-SQL
    INSERT INTO taxon_names(scientific_name, created_at, updated_at)
      SELECT DISTINCT INITCAP(BTRIM(#{TMP_TABLE}.Name)), current_date, current_date
      FROM #{TMP_TABLE}
      WHERE NOT EXISTS (
        SELECT scientific_name
        FROM taxon_names
        WHERE UPPER(BTRIM(scientific_name)) = UPPER(BTRIM(#{TMP_TABLE}.Name))
      )
      AND UPPER(BTRIM(#{TMP_TABLE}.Name)) <> 'NULL'
      AND UPPER(BTRIM(#{TMP_TABLE}.Rank)) = UPPER('#{rank}')
      AND (
        BTRIM(#{TMP_TABLE}.Taxonomy) iLIKE '%CITES%'
        OR BTRIM(#{TMP_TABLE}.Taxonomy) iLIKE '%CMS%'
      )
  SQL
  ActiveRecord::Base.connection.execute(sql)

  [Taxonomy::CITES_EU, Taxonomy::CMS].each do |taxonomy|
    taxonomy = Taxonomy.find_by_name(taxonomy)
    sql = <<-SQL
      INSERT INTO taxon_concepts(
        taxon_name_id, rank_id, taxonomy_id, parent_id,
        author_year, legacy_id, legacy_type, notes, name_status,
        created_at, updated_at
      )
      SELECT
        tmp.taxon_name_id, #{rank_id}, tmp.taxonomy_id,
        parent_taxon_concepts.id,
        CASE
          WHEN UPPER(BTRIM(tmp.author)) = 'NULL' THEN NULL
          ELSE BTRIM(tmp.author)
        END,
        tmp.legacy_id, '#{kingdom}', tmp.notes,
        --'#{synonyms ? 'S' : 'A'}', --TODO why not just copy over the status?
        UPPER(BTRIM(tmp.status)),
        current_date, current_date
      FROM (
        SELECT DISTINCT
          taxon_names.id AS taxon_name_id, #{TMP_TABLE}.parent_rank,
          #{TMP_TABLE}.parent_legacy_id, #{taxonomy.id} AS taxonomy_id,
          BTRIM(#{TMP_TABLE}.author) AS author, #{TMP_TABLE}.legacy_id,
          '#{kingdom}', #{TMP_TABLE}.notes, #{TMP_TABLE}.status
        FROM #{TMP_TABLE}
        INNER JOIN taxon_names
          ON UPPER(BTRIM(#{TMP_TABLE}.name)) = UPPER(BTRIM(taxon_names.scientific_name))
        WHERE
        NOT EXISTS (
          SELECT
            taxon_concepts.taxon_name_id, taxon_concepts.parent_id,
            taxon_concepts.rank_id, taxon_concepts.taxonomy_id
          FROM taxon_concepts
          LEFT JOIN taxon_concepts parent_taxon_concepts
            ON taxon_concepts.parent_id = parent_taxon_concepts.id
            AND parent_taxon_concepts.legacy_id =
              #{TMP_TABLE}.parent_legacy_id
            AND UPPER(parent_taxon_concepts.legacy_type) = UPPER('#{kingdom}')
          LEFT JOIN ranks parent_ranks
            ON parent_taxon_concepts.rank_id = parent_ranks.id
            AND UPPER(BTRIM(parent_ranks.name)) =
              UPPER(BTRIM(#{TMP_TABLE}.parent_rank))
          WHERE
            taxon_concepts.taxon_name_id = taxon_names.id AND
            taxon_concepts.rank_id = #{rank_id} AND
            taxon_concepts.taxonomy_id = #{taxonomy.id} AND
            taxon_concepts.name_status = UPPER(BTRIM(#{TMP_TABLE}.status)) AND
            (
              parent_taxon_concepts.legacy_id = #{TMP_TABLE}.parent_legacy_id
              OR #{TMP_TABLE}.parent_legacy_id IS NULL
            )
        )
        AND UPPER(BTRIM(#{TMP_TABLE}.rank)) = UPPER('#{rank}')
        AND UPPER(BTRIM(#{TMP_TABLE}.taxonomy)) LIKE UPPER('%#{taxonomy.name}%')
        #{ unless synonyms then "AND UPPER(BTRIM(#{TMP_TABLE}.status)) = 'A'" end }
      ) as tmp
      LEFT JOIN ranks parent_ranks
        ON UPPER(BTRIM(parent_ranks.name)) = UPPER(BTRIM(tmp.parent_rank))
      LEFT JOIN taxon_concepts parent_taxon_concepts
        ON (
          parent_taxon_concepts.legacy_id = tmp.parent_legacy_id AND
          parent_taxon_concepts.rank_id = parent_ranks.id AND
          parent_taxon_concepts.legacy_type = '#{kingdom}' AND
          parent_taxon_concepts.taxonomy_id = #{taxonomy.id} --AND
          --(tmp.parent_rank IS NOT NULL OR UPPER(BTRIM(tmp.parent_rank)) <> 'NULL')
        )
      WHERE NOT EXISTS (
        SELECT * FROM taxon_concepts AS tc2
        WHERE
          tc2.taxon_name_id = tmp.taxon_name_id AND
          tc2.rank_id = #{rank_id} AND
          tc2.taxonomy_id = tmp.taxonomy_id AND
          (
            tc2.parent_id IS NULL AND parent_taxon_concepts.id IS NULL
            OR tc2.parent_id = parent_taxon_concepts.id
          ) AND
          tc2.legacy_id = tmp.legacy_id AND
          UPPER(BTRIM(tc2.legacy_type)) = UPPER('#{kingdom}') AND
          UPPER(BTRIM(tc2.author_year)) =
            CASE
              WHEN UPPER(BTRIM(tmp.author)) = 'NULL' THEN NULL
              ELSE BTRIM(tmp.author)
            END
      )
      RETURNING id;
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "#{TaxonConcept.where(:rank_id => rank_id).count - existing} #{rank} added"
  end
end
