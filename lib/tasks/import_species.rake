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
      db_columns = db_columns_from_csv_headers(file, TMP_TABLE, false)
      #import_data_for Rank::KINGDOM
      import_data_for Rank::PHYLUM
      import_data_for Rank::CLASS
      import_data_for Rank::ORDER
      import_data_for Rank::FAMILY
      import_data_for Rank::SUBFAMILY
      import_data_for Rank::GENUS
      import_data_for Rank::SPECIES
      import_data_for Rank::SUBSPECIES
    end
  end
end

# Copies data from the temporary table to the correct tables in the database
#
# @param [String] which the rank to be copied.
def import_data_for rank
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
        WHERE INITCAP(scientific_name) LIKE INITCAP(BTRIM(#{TMP_TABLE}.Name))
      ) AND BTRIM(#{TMP_TABLE}.Name) <> 'NULL' AND BTRIM(#{TMP_TABLE}.Rank) iLIKE '#{rank}' AND BTRIM(#{TMP_TABLE}.Designation) iLIKE '%CITES%'
  SQL
  ActiveRecord::Base.connection.execute(sql)

  cites = Designation.find_by_name(Designation::CITES)
  sql = <<-SQL
    INSERT INTO taxon_concepts(taxon_name_id, rank_id, designation_id, parent_id, created_at, updated_at, author_year, legacy_id, legacy_type )
       SELECT
         tmp.taxon_name_id
         ,#{rank_id}
         ,tmp.designation_id
         ,taxon_concepts.id
         ,current_date
         ,current_date
         ,CASE
            WHEN tmp.author = 'Null' THEN NULL
            ELSE tmp.author
          END
         ,tmp.RecID, 'Animalia'
       FROM
        (
          SELECT DISTINCT taxon_names.id AS taxon_name_id,#{TMP_TABLE}.ParentRank, #{TMP_TABLE}.ParentRecID,
           #{cites.id} AS designation_id,INITCAP(BTRIM(#{TMP_TABLE}.author)) AS author, #{TMP_TABLE}.RecID, 'Animalia'
          FROM #{TMP_TABLE}
          LEFT JOIN taxon_names ON (INITCAP(BTRIM(#{TMP_TABLE}.Name)) LIKE INITCAP(BTRIM(taxon_names.scientific_name)))
          WHERE NOT EXISTS (
            SELECT taxon_name_id, rank_id, designation_id
            FROM taxon_concepts
            WHERE taxon_concepts.taxon_name_id = taxon_names.id AND
              taxon_concepts.rank_id = #{rank_id} AND
              taxon_concepts.designation_id = #{cites.id}
          )
          AND taxon_names.id IS NOT NULL
          AND BTRIM(#{TMP_TABLE}.rank) ilike '#{rank}'
          AND BTRIM(#{TMP_TABLE}.designation) ilike '%CITES%'
        ) as tmp
        LEFT JOIN ranks ON INITCAP(BTRIM(ranks.name)) LIKE INITCAP(BTRIM(tmp.ParentRank))
        LEFT JOIN taxon_concepts ON (
          taxon_concepts.legacy_id = tmp.ParentRecID AND
          taxon_concepts.rank_id = ranks.id AND
          taxon_concepts.legacy_type = 'Animalia' AND
          (tmp.ParentRank <> NULL OR tmp.ParentRank <> 'Null')
        )
    RETURNING id;
  SQL

  ActiveRecord::Base.connection.execute(sql)
  puts "#{TaxonConcept.where(:rank_id => rank_id).count - existing} #{rank} added"
end
