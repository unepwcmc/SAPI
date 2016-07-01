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

  task :ec_srg => [:environment] do
    file = 'lib/files/SRG_meetings_and_SoCs_for_IT_CSV.csv'
    copy_data_into_table(file, 'events', %w(name effective_at url created_at updated_at type))
    puts "There are now #{EcSrg.count} EcSrg events in the database"
  end

  task :eu_annex_regulations_end_dates => [:environment] do
    TMP_TABLE = "eu_annex_regulations_end_dates_import"
    file = "lib/files/eu_annex_regulations_end_dates_utf8.csv"
    drop_table(TMP_TABLE)
    create_table_from_csv_headers(file, TMP_TABLE)
    copy_data(file, TMP_TABLE)

    sql = <<-SQL
      WITH eu_annex_regulations AS (
        SELECT events.id, e.end_date FROM
        #{TMP_TABLE} e
        JOIN events
        ON events.type = 'EuRegulation'
        AND UPPER(SQUISH(events.name)) = UPPER(SQUISH(e.name))
      )
      UPDATE events
      SET end_date = e.end_date
      FROM eu_annex_regulations e
      WHERE e.id = events.id;
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  task :cites_cops_start_dates => [:environment] do
    TMP_TABLE = "cites_cops_start_dates_import"
    file = "lib/files/cites_cops_start_dates.csv"
    drop_table(TMP_TABLE)
    create_table_from_csv_headers(file, TMP_TABLE)
    copy_data(file, TMP_TABLE)

    sql = <<-SQL
      WITH cites_cops AS (
        SELECT events.id, e.start_date FROM
        #{TMP_TABLE} e
        JOIN events
        ON events.type = 'CitesCop'
        AND UPPER(SQUISH(events.name)) = UPPER(SQUISH(e.name))
      )
      UPDATE events
      SET effective_at = e.start_date
      FROM cites_cops e
      WHERE e.id = events.id;
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

end
