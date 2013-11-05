namespace :downloads do

  namespace :cache do
    task :clear => :"clear:all"
    namespace :clear do
      desc "Remove CITES Checklist and Species+ listings downloads"
      task :listings => :environment do
        DownloadsCache.clear_listings
      end
      desc "Remove all CITES Checklist and Species+ downloads"
      task :all => :environment do
        DownloadsCache.clear_all
      end
    end

    desc "Keeps most recently used downloads"
    task :rotate => :environment do
      DownloadsCache.rotate_all
    end

    desc "Update the cache for the featured Checklist downloads"
    task :update_checklist_downloads => :environment do
      DownloadsCache.update_checklist_downloads
    end

    desc "Update the cache for the featured Species+ downloads"
    task :update_species_downloads => :environment do
      DownloadsCache.update_species_downloads
    end
  end
end
