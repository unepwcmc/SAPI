namespace :import do

  desc 'Import languages from csv file (usage: rake import:languages[path/to/file,path/to/another])'
  task :languages, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'languages_import'
    puts "There are #{Language.count} languages in the database."
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      sql = <<-SQL
        INSERT INTO "languages" (name_en, iso_code3, iso_code1, created_at, updated_at)
        SELECT name_en, UPPER(iso_code3), UPPER(iso_code1), current_date, current_date
          FROM #{TMP_TABLE}
          WHERE NOT EXISTS (
            SELECT iso_code3
            FROM "languages"
            WHERE UPPER("languages".iso_code3) = UPPER(#{TMP_TABLE}.iso_code3)
          )
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end
    puts "There are now #{Language.count} languages in the database"
  end

end
