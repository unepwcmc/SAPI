namespace :import do
  desc 'Runs all import tasks'
  task :all => :environment do
    Rake::Task["db:seed"].invoke
    Rake::Task["import:species"].invoke(
      'lib/assets/files/animals.csv',
      'lib/assets/files/plants.csv'
    )
    Rake::Task["import:cites_regions"].invoke
    Rake::Task["import:countries"].invoke
    Rake::Task["import:distributions"].invoke(
      'lib/assets/files/animals_distributions.csv',
      'lib/assets/files/plants_distributions.csv'
    )
    Rake::Task["import:cites_listings"].invoke(
      'lib/assets/files/animals_complex_CITES_listings.csv'#TODO missing 'complex' listing for plants
    )
    Rake::Task["import:common_names"].invoke(
      'lib/assets/files/animals_common_names.csv',
      'lib/assets/files/plants_common_names.csv'
    )
    Sapi::fix_listing_changes()
    Sapi::rebuild()
  end

  desc 'Runs import tasks for the first pages of CITES checklist (both animals and plants)'
  task :first_pages => :environment do
    Rake::Task["db:seed"].invoke
    Rake::Task["import:species"].invoke(
      'lib/assets/files/first_pages_of_animals/taxon_concepts.csv',
      'lib/assets/files/first_pages_of_plants/taxon_concepts.csv'
    )
    Rake::Task["import:cites_regions"].invoke
    Rake::Task["import:countries"].invoke
    Rake::Task["import:distributions"].invoke(
      'lib/assets/files/first_pages_of_animals/distributions.csv',
      'lib/assets/files/first_pages_of_plants/distributions.csv'
    )
    Rake::Task["import:cites_listings"].invoke(
      'lib/assets/files/first_pages_of_animals/listing_changes.csv',
      'lib/assets/files/first_pages_of_plants/listing_changes.csv'
    )
    Rake::Task["import:common_names"].invoke(
      'lib/assets/files/first_pages_of_animals/common_names.csv',
      'lib/assets/files/first_pages_of_plants/common_names.csv'
    )
    Sapi::fix_listing_changes()
    Sapi::rebuild()
  end

end
