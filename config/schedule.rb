every :day, :at => '4:30am' do
  rake "downloads:cache:rotate"
end

every :day, :at => '5:30am' do
  rake "downloads:cache:update"
end
