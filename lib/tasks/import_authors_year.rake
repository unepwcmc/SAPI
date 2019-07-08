require Rails.root.join('lib/tasks/helpers_for_import.rb')
namespace :import do

  desc 'update author_year TaxonConcept attribute'
  task :authors_year => [:environment] do
    TMP_TABLE = "author_year_import"
    file = "lib/files/Orchids_author_changes.csv"
    byebug
    drop_table(TMP_TABLE)
    create_table_from_csv_headers(file, TMP_TABLE)
    copy_data(file, TMP_TABLE)
    sql = <<-SQL
      UPDATE taxon_concepts tc
      SET author_year = t.author
      FROM #{TMP_TABLE} t
      WHERE t.legacy_id = tc.id
    SQL
    ActiveRecord::Base.connection.execute(sql)
    count = TaxonConcept.where(updated_at: Date.today).count
    puts "#{count} TaxonConcepts updated"
  end
end
