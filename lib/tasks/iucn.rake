namespace :iucn do

  desc 'Update mapping between CITES species and IUCN species'
  task :mapping => :environment do
    Admin::IucnMapping.create_mappings
  end
end
