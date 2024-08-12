namespace :import do
  desc 'Removes all import tables'
  task cleanup: :environment do
    pg_res = ApplicationRecord.connection.execute(
      "SELECT table_name FROM information_schema.tables WHERE table_name LIKE '%_import'"
    )
    pg_res.each do |row|
      ApplicationRecord.connection.execute("DROP TABLE #{row['table_name']} CASCADE")
    end
    puts 'Would be useful to run VACUUM ANALYZE now'
  end
end
