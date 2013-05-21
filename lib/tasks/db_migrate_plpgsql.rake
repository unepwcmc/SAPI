namespace :db do
  namespace :migrate do
    desc "Migrate views"
    task :views => :environment do
      files = Dir.glob(Rails.root.join("db/views/*.sql"))
      files.sort.each do |file|
        puts file
        ActiveRecord::Base.connection.execute(File.read(file))
      end
    end
    desc "Migrate plpgsql procedures and types"
    task :plpgsql => :environment do
      files = Dir.glob(Rails.root.join("db/plpgsql/*.sql"))
      files.sort.each do |file|
        puts file
        ActiveRecord::Base.connection.execute(File.read(file))
      end
    end
  end
  task :migrate do
    Rake::Task['db:migrate:views'].invoke
    Rake::Task['db:migrate:plpgsql'].invoke
  end
end
