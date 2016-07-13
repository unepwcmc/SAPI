namespace :import do

  desc 'Import references from csv file (usage: rake import:references[path/to/file,path/to/another])'
  task :references, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'references_import'
    puts "There are #{Reference.count} references in the database."
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      kingdom = file.split('/').last.split('_')[0].titleize

      sql = <<-SQL
        DELETE FROM references_legacy_id_mapping;

        WITH references_with_aliases AS (
          WITH references_with_aliases_before_cast AS (
            SELECT split_part(legacy_ids,':',1) AS legacy_id,
            regexp_split_to_table(legacy_ids, ':') AS alias_legacy_id
            FROM #{TMP_TABLE}
          )
          SELECT legacy_id::INT, '#{kingdom}' AS legacy_type,
            NULLIF(alias_legacy_id, '')::INT AS alias_legacy_id
          FROM references_with_aliases_before_cast
          WHERE NULLIF(alias_legacy_id, '') IS NOT NULL AND legacy_id::INT != NULLIF(alias_legacy_id, '')::INT
        )
        INSERT INTO references_legacy_id_mapping (
          legacy_id, legacy_type, alias_legacy_id
        )
        SELECT legacy_id, legacy_type, alias_legacy_id FROM references_with_aliases
        WHERE NOT EXISTS (
          SELECT * FROM references_legacy_id_mapping map
          WHERE map.legacy_id = legacy_id AND map.legacy_type = legacy_type
            AND map.alias_legacy_id = alias_legacy_id
        );

        INSERT INTO "references" (
          legacy_type, legacy_id,
          citation, author, title, publisher, year,
          created_at, updated_at
        )
        SELECT '#{kingdom}', split_part(legacy_ids,':',1)::INT,
          citation_to_use, author, COALESCE(title, ''), publisher, pub_year,
          current_date, current_date
          FROM #{TMP_TABLE}
          WHERE NOT EXISTS (
            SELECT legacy_type, legacy_id
            FROM "references"
            WHERE "references".legacy_id = split_part(#{TMP_TABLE}.legacy_ids,':',1)::INT AND
              "references".legacy_type = '#{kingdom}'
          )
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end
    puts "There are now #{Reference.count} references in the database"
  end

end
