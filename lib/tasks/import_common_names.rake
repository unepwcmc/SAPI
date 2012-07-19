namespace :import do

  desc 'Import common names from csv file [usage: rake import:common_names[path/to/file,path/to/another]'
  task :common_names, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'common_name_import'
    puts "There are #{CommonName.count} common names in the database."
    puts "There are #{TaxonCommon.count} taxon commons in the database."
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)
      sql = <<-SQL
        INSERT INTO common_names(name, language_id, created_at, updated_at)
        SELECT common_name, languages.id, current_date, current_date
          FROM #{TMP_TABLE}
          LEFT JOIN languages ON #{TMP_TABLE}.language_name = languages.name
          WHERE NOT EXISTS (
            SELECT common_names.name
              FROM common_names
              LEFT JOIN languages ON common_names.language_id = languages.id
              WHERE common_names.name = #{TMP_TABLE}.common_name AND #{TMP_TABLE}.language_name = languages.name
          );
  
        INSERT INTO taxon_commons(taxon_concept_id, common_name_id, created_at, updated_at)
        SELECT DISTINCT species.id, common_names.id, current_date, current_date
          FROM #{TMP_TABLE}
          LEFT JOIN common_names ON #{TMP_TABLE}.common_name = common_names.name
          LEFT JOIN languages ON #{TMP_TABLE}.language_name = languages.name
          LEFT JOIN taxon_concepts as species ON species.legacy_id = species_id
          WHERE Species.id IS NOT NULL
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end
    puts "There are now #{CommonName.count} common names in the database"
    puts "There are #{TaxonCommon.count} taxon commons in the database."
  end

end
