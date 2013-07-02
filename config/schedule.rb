every :day, :at => '2:42am' do
  rake "db:migrate:rebuild_taxon_concepts_mview"
end

every :day, :at => '3:42am' do
  rake "db:migrate:rebuild_taxon_concepts_mview"
end

every :day, :at => '4:42am' do
  rake "downloads:cache:update"
end

every :day, :at => '5:42am' do
  rake "downloads:cache:rotate"
end
