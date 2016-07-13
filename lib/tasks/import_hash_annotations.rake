namespace :import do

  desc 'Import hash annotations from csv file (usage: rake import:hash_annotations[path/to/file,path/to/another])'
  task :hash_annotations, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'hash_annotations_import'
    puts "There are #{Annotation.count} annotations in the database."
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      designation_id = Designation.find_by_name(file.split('.')[0].split('_')[2].upcase).id

      sql = <<-SQL
        INSERT INTO annotations (symbol, parent_symbol, event_id, full_note_en, created_at, updated_at)
        SELECT subquery.*, NOW(), NOW()
        FROM (
          SELECT BTRIM(symbol), BTRIM(events.name), events.id, BTRIM(full_note_en)
          FROM #{TMP_TABLE}
          INNER JOIN events ON events.legacy_id = #{TMP_TABLE}.event_legacy_id
            AND events.designation_id = #{designation_id}

          EXCEPT

          SELECT symbol, parent_symbol, event_id, full_note_en
          FROM annotations

        ) AS subquery
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end
    puts "There are now #{Annotation.count} hash_annotations in the database"
  end

  desc 'Import hash annotation translations'
  task :hash_annotations_cites_translations => [:environment] do
    TMP_TABLE = "hash_annotations_translations_import"
    file = "lib/files/hash_annotations_cites_translations.csv"
    drop_table(TMP_TABLE)
    create_table_from_csv_headers(file, TMP_TABLE)
    copy_data(file, TMP_TABLE)

    res = ActiveRecord::Base.connection.execute("SELECT COUNT(*) FROM #{TMP_TABLE}")
    puts "Attempting to import #{res[0]['count']} rows"

    sql = <<-SQL
      WITH translated_annotations AS (
        SELECT
        annotations.id,
        translations.full_note_es,
        translations.full_note_fr
        FROM #{TMP_TABLE} translations
        JOIN events
        ON events.legacy_id = translations.event_legacy_id
        JOIN designations
        ON events.designation_id = designations.id
          AND designations.name = 'CITES'
        JOIN annotations
        ON events.id = annotations.event_id
          AND BTRIM(translations.symbol) = BTRIM(annotations.symbol)
      )
      UPDATE annotations
      SET full_note_es = ta.full_note_es, full_note_fr = ta.full_note_fr
      FROM translated_annotations ta
      WHERE ta.id = annotations.id
    SQL

    res = ActiveRecord::Base.connection.execute(sql)

    puts "Updated #{res.cmd_tuples} rows"
  end

end
