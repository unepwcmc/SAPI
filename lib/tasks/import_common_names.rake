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
      ActiveRecord::Base.connection.execute("CREATE INDEX ON #{TMP_TABLE} (name, language, rank)")
      copy_data(file, TMP_TABLE)
      kingdom = file.split('/').last.split('_')[0].titleize


      puts "Adding any missing languages"
      puts "There are #{Language.count} languages in the database"
      sql = <<-SQL
        INSERT INTO languages(iso_code3, created_at, updated_at)
        SELECT DISTINCT LOWER(BTRIM(#{TMP_TABLE}.language)), current_date, current_date
        FROM #{TMP_TABLE}
        WHERE NOT EXISTS (
          SELECT id FROM languages
          WHERE UPPER(iso_code3) = UPPER(BTRIM(#{TMP_TABLE}.language))
        );
      SQL
      ActiveRecord::Base.connection.execute(sql)
      puts "There are now #{Language.count} languages in the database"

      sql = <<-SQL
        INSERT INTO common_names(name, language_id, created_at, updated_at)
        SELECT #{TMP_TABLE}.name, languages.id, current_date, current_date
          FROM #{TMP_TABLE}
          INNER JOIN languages ON UPPER(#{TMP_TABLE}.language) = UPPER(languages.iso_code3)
          WHERE NOT EXISTS (
            SELECT common_names.name
              FROM common_names
              LEFT JOIN languages ON common_names.language_id = languages.id
              WHERE common_names.name = #{TMP_TABLE}.name AND UPPER(BTRIM(#{TMP_TABLE}.language)) = UPPER(languages.iso_code3)
          ) AND ( UPPER(BTRIM(#{TMP_TABLE}.designation)) like '%CITES%' OR UPPER(BTRIM(#{TMP_TABLE}.designation)) like '%EU%');

        INSERT INTO taxon_commons(taxon_concept_id, common_name_id, created_at, updated_at)
        SELECT DISTINCT taxon_concepts.id, common_names.id, current_date, current_date
          FROM #{TMP_TABLE}
          INNER JOIN common_names ON #{TMP_TABLE}.name = common_names.name
          INNER JOIN languages ON UPPER(#{TMP_TABLE}.language) = UPPER(languages.iso_code3)
          LEFT JOIN ranks ON UPPER(BTRIM(#{TMP_TABLE}.rank)) = UPPER(ranks.name)
          LEFT JOIN taxon_concepts ON taxon_concepts.legacy_id = #{TMP_TABLE}.legacy_id AND taxon_concepts.legacy_type = '#{kingdom}' AND taxon_concepts.rank_id = ranks.id
          WHERE taxon_concepts.id IS NOT NULL AND NOT EXISTS (
            SELECT id FROM taxon_commons
            WHERE taxon_commons.taxon_concept_id = taxon_concepts.id AND
              taxon_commons.common_name_id = common_names.id
          );
      SQL
      ActiveRecord::Base.connection.execute(sql)
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
