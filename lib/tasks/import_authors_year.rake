require Rails.root.join('lib/tasks/helpers_for_import.rb')

namespace :import do
  desc 'update author_year TaxonConcept attribute (usage: rake import:authors_year[path/to/file])'
  task :authors_year, 10.times.map { |i| :"file_#{i}" } => [ :environment ] do |t, args|
    import_helper = CsvImportHelper.new

    TMP_TABLE = 'author_year_import'
    files = import_helper.files_from_args(t, args)
    files.each do |file|
      import_helper.drop_table(TMP_TABLE)
      import_helper.create_table_from_csv_headers(file, TMP_TABLE)
      import_helper.copy_data(file, TMP_TABLE)

      sql = <<-SQL.squish
        UPDATE taxon_concepts tc
        SET author_year = t.author, updated_at = NOW()
        FROM #{TMP_TABLE} t
        WHERE t.legacy_id = tc.id
      SQL

      ApplicationRecord.connection.execute(sql)
    end

    count = TaxonConcept.where('updated_at > ?', Date.today).count

    puts "#{count} TaxonConcepts updated"
  end
end
