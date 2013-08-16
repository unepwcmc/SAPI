every :day, :at => '2:42am' do
  rake "db:migrate:rebuild_taxon_concepts_mview"
end

every :day, :at => '3:42am' do
  rake "db:migrate:rebuild_listing_changes_mview"
end

every :day, :at => '4:42am' do
  rake "downloads:cache:update_checklist_downloads"
  rake "downloads:cache:update_species_downloads"
end

every :day, :at => '5:42am' do
  rake "downloads:cache:rotate"
end
