namespace :dashboard_stats do

  namespace :cache do
    desc "Update the cache for the dashboard stats"
    task :update => :environment do
      DashboardStatsCache.update_dashboard_stats
    end
  end
end
