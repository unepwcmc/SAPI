namespace :iucn do

  desc 'Update mapping between CITES species and IUCN species'
  task :mapping => :environment do
    Admin::IucnMappingManager.sync()
  end
end
