namespace :downloads do

  namespace :cache do
    desc "Remove all CITES Checklist and Species+ downloads"
    task :clear => :environment do
      DownloadsCache.clear
    end

    desc "Update the cache for the featured downloads"
    task :update => :environment do
      DownloadsCache.update
    end

    desc "Update the cache for the checklist downloads"
    task :update_checklist_downloads => :environment do
      DownloadsCache.update_checklist_downloads
    end

  end
end
