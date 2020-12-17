require Rails.root.join('lib/tasks/helpers_for_import.rb')
namespace :import do

  desc 'update author_year TaxonConcept attribute (usage: rake import:authors_year[path/to/file])'
  task :authors_year, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = "author_year_import"
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)
      sql = <<-SQL
        UPDATE taxon_concepts tc
        SET author_year = t.author, updated_at = NOW()
        FROM #{TMP_TABLE} t
        WHERE t.legacy_id = tc.id
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end
    count = TaxonConcept.where('updated_at > ?', Date.today).count
    puts "#{count} TaxonConcepts updated"
  end
end
