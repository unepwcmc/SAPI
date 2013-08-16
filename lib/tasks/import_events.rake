namespace :import do

  desc 'Import events from csv file (usage: rake import:events[path/to/file,path/to/another])'
  task :events, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'events_import'
    puts "There are #{Event.count} events in the database."
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      sql = <<-SQL
        INSERT INTO "events" (legacy_id, designation_id, name, description, url, effective_at, type, subtype, created_at, updated_at)
        SELECT legacy_id, designations.id, #{TMP_TABLE}.name, description, url, effective_at,
          CASE
            WHEN BTRIM(#{TMP_TABLE}.type) = 'Basic and amendments' THEN 'EuRegulation'
            WHEN BTRIM(#{TMP_TABLE}.type) = 'Suspension' THEN 'EuSuspensionRegulation'
            WHEN BTRIM(#{TMP_TABLE}.type) = 'CITES Suspension Notification' THEN 'CitesSuspensionNotification'
            WHEN BTRIM(#{TMP_TABLE}.type) = 'CITES CoP' THEN 'CitesCop'
          END
          ,subtype
          ,current_date, current_date
          FROM #{TMP_TABLE}
          INNER JOIN designations ON UPPER(designations.name) = UPPER(BTRIM(#{TMP_TABLE}.designation))
          WHERE #{TMP_TABLE}.name IS NOT NULL AND #{TMP_TABLE}.name != 'NULL' AND NOT EXISTS (
            SELECT name
            FROM "events"
            WHERE "events".name = #{TMP_TABLE}.name
          )
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end
    puts "There are now #{Event.count} events in the database"
  end

end
