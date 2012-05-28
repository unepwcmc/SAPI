namespace :import do
  desc 'Runs all import tasks'
  task :all => :environment do
    Rake::Task["db:seed"].invoke
    Rake::Task["import:species"].invoke
    Rake::Task["import:cites_regions"].invoke
    Rake::Task["import:countries"].invoke
    Rake::Task["import:distributions"].invoke
  end
end
