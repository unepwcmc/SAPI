namespace :import do
  desc 'Runs all import tasks'
  task :all => :environment do
    Rake::Task["db:seed"].invoke
    ENV["FILE"] = nil
    Rake::Task["import:species"].invoke
    ENV["FILE"] = nil
    Rake::Task["import:cites_regions"].invoke
    ENV["FILE"] = nil
    Rake::Task["import:countries"].invoke
    ENV["FILE"] = nil
    Rake::Task["import:distributions"].invoke
  end
end
