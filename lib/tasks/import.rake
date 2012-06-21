namespace :import do
  desc 'Runs all import tasks'
  task :all => :environment do
    Rake::Task["db:seed"].invoke
    Rake::Task["import:species"].invoke
    Rake::Task["import:cites_regions"].invoke
    Rake::Task["import:countries"].invoke
    Rake::Task["import:distributions"].invoke
    Rake::Task["import:cites_listings"].invoke
    ActiveRecord::Base.connection.execute('SELECT * FROM insert_cites_listing_deletions()')
    ActiveRecord::Base.connection.execute('SELECT * FROM sapi_rebuild()')
  end
end
