set :output, 'log/cron.log'

every :saturday, :at => '1:42am' do
  rake "db:migrate:rebuild"
end

every :day, :at => '4:05am' do
  rake "downloads:cache:update"
end

every :sunday, :at => '4:45am' do
  rake "dashboard_stats:cache:update"
  rake "db:common_names:cleanup"
  rake "db:taxon_names:cleanup"
end

every 5.minutes do
  rake "elibrary:refresh_document_search"
end

every 1.day, :at => '5:30 am' do
  rake "-s sitemap:refresh"
end
