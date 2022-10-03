namespace :import do

  desc 'Import common names from csv file (usage: rake import:common_names[path/to/file,path/to/another])'
  task :common_names, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'common_name_import'
    puts "There are #{CommonName.count} common names in the database."
    puts "There are #{TaxonCommon.count} taxon commons in the database."
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)
      ActiveRecord::Base.connection.execute("CREATE INDEX ON #{TMP_TABLE} (name, language, rank)")

      sql = <<-SQL
        INSERT INTO common_names(name, language_id, created_at, updated_at)
        SELECT subquery.*, NOW(), NOW()
        FROM (
          SELECT DISTINCT ON( BTRIM(UPPER(#{TMP_TABLE}.name)), languages.id) #{TMP_TABLE}.name,
            languages.id
          FROM #{TMP_TABLE}
          INNER JOIN languages ON UPPER(#{TMP_TABLE}.language) = UPPER(languages.iso_code3)

          EXCEPT

          SELECT name, language_id
          FROM common_names
        ) AS subquery;
      SQL
      ActiveRecord::Base.connection.execute(sql)

      [Taxonomy::CITES_EU, Taxonomy::CMS].each do |taxonomy_name|
        puts "Import #{taxonomy_name} common names"
        taxonomy = Taxonomy.find_by_name(taxonomy_name)
        sql = <<-SQL

          INSERT INTO taxon_commons(taxon_concept_id, common_name_id, created_at, updated_at)
          SELECT subquery.*, NOW(), NOW()
          FROM (
            SELECT DISTINCT taxon_concepts.id, common_names.id
            FROM #{TMP_TABLE}
            INNER JOIN common_names ON UPPER(BTRIM(#{TMP_TABLE}.name)) = UPPER(common_names.name)
            INNER JOIN languages ON UPPER(#{TMP_TABLE}.language) = UPPER(languages.iso_code3)
            LEFT JOIN ranks ON UPPER(BTRIM(#{TMP_TABLE}.rank)) = UPPER(ranks.name)
            LEFT JOIN taxon_concepts ON taxon_concepts.id = #{TMP_TABLE}.legacy_id
              AND taxon_concepts.rank_id = ranks.id
            LEFT JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
            WHERE taxon_concepts.id IS NOT NULL AND taxonomies.id = #{taxonomy.id}

            EXCEPT

            SELECT taxon_concept_id, common_name_id
            FROM taxon_commons
          ) AS subquery
        SQL
        ActiveRecord::Base.connection.execute(sql)
      end

      # The import process allows duplicates to enter the db, as well as case-insensitive duplicates.
      # We can delete these here, by grouping by common name converted to lowercase, language,
      # taxon_concept and taxonomy, and only keeping the first example.
      sql = <<-SQL
        SELECT min(taxon_commons.id)
        FROM taxon_commons
        LEFT JOIN common_names ON common_names.id = taxon_commons.common_name_id
        LEFT JOIN taxon_concepts ON taxon_concepts.id = taxon_commons.taxon_concept_id
        GROUP BY LOWER(common_names.name), common_names.language_id, taxon_commons.taxon_concept_id, taxon_concepts.taxonomy_id
      SQL
      taxon_commons_ids_unique = ActiveRecord::Base.connection.execute(sql).values.flatten
      taxon_commons_duplicates = TaxonCommon.where.not(id: taxon_commons_ids_unique)
      taxon_commons_duplicates.destroy_all
    end
    puts "There are now #{CommonName.count} common names in the database"
    puts "There are now #{TaxonCommon.count} taxon commons in the database."
  end

  namespace :common_names do
    desc 'Delete all existing common names, and taxon commons'
    task :delete_all => :environment do
      puts "Deleting #{TaxonCommon.delete_all} taxon commons"
      puts "Deleting #{CommonName.delete_all} common names"
    end
  end
end
