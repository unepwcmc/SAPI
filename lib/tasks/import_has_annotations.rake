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
        SELECT BTRIM(symbol), BTRIM(events.name), events.id, BTRIM(full_note_en), current_date, current_date
          FROM #{TMP_TABLE}
          INNER JOIN events ON events.legacy_id = #{TMP_TABLE}.event_legacy_id
            AND events.designation_id = #{designation_id}
          WHERE  NOT EXISTS (
            SELECT id
            FROM annotations
            WHERE UPPER(annotations.symbol) = BTRIM(UPPER(#{TMP_TABLE}.symbol))
              AND UPPER(annotations.full_note_en) = BTRIM(UPPER(#{TMP_TABLE}.full_note_en))
              AND annotations.event_id = events.id
          )
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end
    puts "There are now #{Annotation.count} hash_annotations in the database"
  end

end

