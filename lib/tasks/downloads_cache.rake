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
  end
end
