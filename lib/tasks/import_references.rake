namespace :import do

  desc 'Import references from SQL Server (usage: rake import:references[path/to/file,path/to/another])'
  task :references, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'references_import'
    puts "There are #{Reference.count} references in the database."
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      sql = <<-SQL
        INSERT INTO "references" (legacy_type, legacy_id, author, title, year,
          created_at, updated_at)
        SELECT legacy_type, legacy_id, author, title, year,
          current_date, current_date
          FROM #{TMP_TABLE}
          WHERE title IS NOT NULL AND NOT EXISTS (
            SELECT legacy_type, legacy_id
            FROM "references"
            WHERE "references".legacy_id = #{TMP_TABLE}.legacy_id AND
              "references".legacy_type = #{TMP_TABLE}.legacy_type
          )
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end
    puts "There are now #{Reference.count} references in the database"
  end

end