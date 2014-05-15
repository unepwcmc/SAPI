set :output, 'log/cron.log'

every :day, :at => '1:00am' do
  rake "dasboard:new_relic"
end

every :day, :at => '2:42am' do
  rake "db:migrate:rebuild"
end

every :day, :at => '4:05am' do
  rake "downloads:cache:update"
end

every :sunday, :at => '4:45am' do
  rake "dashboard_stats:cache:update"
end
