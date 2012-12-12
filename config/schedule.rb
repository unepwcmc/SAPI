every :sunday, :at => '4:30am' do
  rake "downloads:cache:rotate"
end

every :day, :at => '12:30am' do
  rake "downloads:cache:update"
end
