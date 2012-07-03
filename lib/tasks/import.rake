namespace :import do
  desc 'Runs all import tasks'
  task :all => :environment do
    Rake::Task["db:seed"].invoke
    Rake::Task["import:species"].invoke
    Rake::Task["import:cites_regions"].invoke
    Rake::Task["import:countries"].invoke
    Rake::Task["import:distributions"].invoke
    Rake::Task["import:cites_listings"].invoke
    Rake::Task["import:common_names"].invoke
    Sapi::fix_listing_changes()
    Sapi::rebuild()
  end
end
