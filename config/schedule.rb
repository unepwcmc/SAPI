every :day, :at => '2:42am' do
  rake "db:migrate:rebuild"
end

every :day, :at => '4:42am' do
  rake "downloads:cache:update_checklist_downloads"
end

every :day, :at => '5:12am' do
  rake "downloads:cache:update_species_downloads"	
end

every :day, :at => '5:42am' do
  rake "downloads:cache:rotate"
end
