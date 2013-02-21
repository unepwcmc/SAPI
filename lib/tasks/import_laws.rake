namespace :import do

  desc 'Import laws from csv file (usage: rake import:laws[path/to/file,path/to/another])'
  task :laws, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'laws_import'
    puts "There are #{Event.count} laws in the database."
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      sql = <<-SQL
        INSERT INTO "events" (name, description, url, effective_at, created_at, updated_at)
        SELECT name, description, url, effective_at, current_date, current_date
          FROM #{TMP_TABLE}
          WHERE name IS NOT NULL AND name != 'NULL' AND NOT EXISTS (
            SELECT name
            FROM "events"
            WHERE "events".name = #{TMP_TABLE}.name
          )
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end
    puts "There are now #{Event.count} laws in the database"
  end

end