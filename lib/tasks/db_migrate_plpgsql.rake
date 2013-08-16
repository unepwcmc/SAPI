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
    desc "Rebuild all materialized views"
    task :rebuild_all => [:rebuild_taxon_concepts_mview, :rebuild_listing_changes_mview]
    desc "Rebuild taxon concepts materialized view"
    task :rebuild_taxon_concepts_mview => [:migrate] do
      Sapi.rebuild(:only => [:taxon_concepts_mview], :disable_triggers => false)
    end
    desc "Rebuild listing changes materialized view"
    task :rebuild_listing_changes_mview => [:migrate] do
      Sapi.rebuild(:only => [:listing_changes_mview], :disable_triggers => false)
    end
  end
  task :migrate do
    Rake::Task['db:migrate:views'].invoke
    Rake::Task['db:migrate:mviews'].invoke
    Rake::Task['db:migrate:plpgsql'].invoke
  end
end
