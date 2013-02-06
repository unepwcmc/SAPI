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
        WHERE UPPER(scientific_name) LIKE UPPER(BTRIM(#{TMP_TABLE}.Name))
      ) AND BTRIM(#{TMP_TABLE}.Name) <> 'NULL' AND BTRIM(#{TMP_TABLE}.Rank) iLIKE '#{rank}' AND
      ( BTRIM(#{TMP_TABLE}.Taxonomy) iLIKE '%CITES%' OR BTRIM(#{TMP_TABLE}.Taxonomy) iLike '%CMS%')
  SQL
  ActiveRecord::Base.connection.execute(sql)

  [Taxonomy::CITES_EU, Taxonomy::CMS].each do |taxonomy|
    taxonomy = Taxonomy.find_by_name(taxonomy)
    sql = <<-SQL
      INSERT INTO taxon_concepts(taxon_name_id, rank_id, taxonomy_id, parent_id, created_at, updated_at, author_year, legacy_id, legacy_type, notes, name_status)
         SELECT
           tmp.taxon_name_id
           ,#{rank_id}
           ,tmp.taxonomy_id
           ,taxon_concepts.id
           ,current_date
           ,current_date
           ,CASE
              WHEN tmp.author = 'Null' THEN NULL
              ELSE tmp.author
            END
           ,tmp.legacy_id, '#{kingdom}', tmp.notes, '#{synonyms ? 'S' : 'A'}'
         FROM
          (
            SELECT DISTINCT taxon_names.id AS taxon_name_id, #{TMP_TABLE}.parent_rank, #{TMP_TABLE}.parent_legacy_id,
             #{taxonomy.id} AS taxonomy_id, INITCAP(BTRIM(#{TMP_TABLE}.author)) AS author, #{TMP_TABLE}.legacy_id, '#{kingdom}', #{TMP_TABLE}.notes
            FROM #{TMP_TABLE}
            LEFT JOIN taxon_names ON UPPER(BTRIM(#{TMP_TABLE}.name)) LIKE UPPER(BTRIM(taxon_names.scientific_name))
            WHERE NOT EXISTS (
              SELECT taxon_name_id, rank_id, taxonomy_id
              FROM taxon_concepts
              WHERE taxon_concepts.taxon_name_id = taxon_names.id AND
                taxon_concepts.rank_id = #{rank_id} AND
                taxon_concepts.taxonomy_id = #{taxonomy.id}
            )
            AND taxon_names.id IS NOT NULL
            AND UPPER(BTRIM(#{TMP_TABLE}.rank)) like UPPER('#{rank}')
            AND BTRIM(#{TMP_TABLE}.taxonomy) ilike '%#{taxonomy.name}%'
            #{ unless synonyms then "AND BTRIM(#{TMP_TABLE}.status) like 'A'" end }
          ) as tmp
          LEFT JOIN ranks ON UPPER(BTRIM(ranks.name)) LIKE UPPER(BTRIM(tmp.parent_rank))
          LEFT JOIN taxon_concepts ON (
            taxon_concepts.legacy_id = tmp.parent_legacy_id AND
            taxon_concepts.rank_id = ranks.id AND
            taxon_concepts.legacy_type = '#{kingdom}' AND
            taxon_concepts.taxonomy_id = #{taxonomy.id} AND
            (tmp.parent_rank <> NULL OR tmp.parent_rank <> 'Null')
          )
          WHERE NOT EXISTS (
            SELECT * FROM taxon_concepts AS tc2
            WHERE tc2.taxon_name_id = tmp.taxon_name_id AND
            tc2.rank_id = #{rank_id} AND
            tc2.taxonomy_id = tmp.taxonomy_id AND
            tc2.parent_id = taxon_concepts.id AND
            tc2.legacy_id = tmp.legacy_id AND
            tc2.legacy_type = '#{kingdom}' AND
            tc2.author_year = CASE
              WHEN tmp.author = 'Null' THEN NULL
              ELSE tmp.author
            END
          )
      RETURNING id;
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "#{TaxonConcept.where(:rank_id => rank_id).count - existing} #{rank} added"
  end
end
