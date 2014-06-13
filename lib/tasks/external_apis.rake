namespace :external_apis do

  desc 'Update mapping between CITES species and IUCN species'
  task :iucn_mapping => :environment do
    Admin::IucnMappingManager.sync()
  end

  desc 'Update mapping between CMS species in Species+ and CMS species'
  task :iucn_mapping => :environment do
    #Admin::CmsMappingManager.sync()
  end
end
