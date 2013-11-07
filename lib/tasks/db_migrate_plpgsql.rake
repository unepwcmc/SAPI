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
    desc "Migrate materialized views"
    task :mviews => :environment do
      files = Dir.glob(Rails.root.join("db/mviews/*.sql"))
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
    desc "Rebuild all computed values"
    task :rebuild => :migrate do
      Sapi.rebuild
    end
  end
  task :migrate do
    Rake::Task['db:migrate:views'].invoke
    Rake::Task['db:migrate:mviews'].invoke
    Rake::Task['db:migrate:plpgsql'].invoke
  end
  desc "Drop sandboxes in progress"
  task :drop_sandboxes => :environment do
    Trade::AnnualReportUpload.where(:is_done => false).delete_all
  end
end
