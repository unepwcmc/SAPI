namespace :db do
  namespace :compliance do
    task :rebuild => :environment do
      Trade::RebuildComplianceMviews.run
    end
  end
end
