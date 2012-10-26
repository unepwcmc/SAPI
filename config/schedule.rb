every :sunday, :at => '4:30am' do
  rake "downloads:cache:rotate"
end
