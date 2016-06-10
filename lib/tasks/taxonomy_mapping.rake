namespace :taxonomy_mapping do

  desc 'Update mapping between CITES species and IUCN species'
  task :iucn_mapping => :environment do
    Admin::IucnMappingManager.sync
  end

  desc 'Update mapping between CMS species in Species+ and CMS species'
  task :cms_mapping => :environment do
    Admin::CmsMappingManager.sync
  end

  desc 'Copy CITES distribution data to CMS species'
  task :fill_cms_distributions => :environment do
    Admin::CmsMappingManager.fill_cms_distributions
  end
end
