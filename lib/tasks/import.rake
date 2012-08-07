namespace :import do
  task :all => "import:random" do; end

  desc 'Runs import tasks for a random subset of CITES checklist (both animals and plants)'
  task :random => :environment do
    Rake::Task["db:seed"].invoke
    Rake::Task["import:species"].invoke(
      'lib/assets/files/random/animals.csv',
      'lib/assets/files/random/plants.csv'
    )
    Rake::Task["import:cites_regions"].invoke(
      'lib/assets/files/cites_regions.csv'
    )
    Rake::Task["import:countries"].invoke(
      'lib/assets/files/countries.csv'
    )
    Rake::Task["import:distributions"].invoke(
      'lib/assets/files/random/animals_distributions.csv',
      'lib/assets/files/random/plants_distributions.csv'
    )
    Rake::Task["import:cites_listings"].invoke(
      'lib/assets/files/random/animals_complex_CITES_listings.csv'#TODO missing 'complex' listing for plants
    )
    Rake::Task["import:common_names"].invoke(
      'lib/assets/files/random/animals_common_names.csv',
      'lib/assets/files/random/plants_common_names.csv'
    )
    Rake::Task["import:synonyms"].invoke(
      'lib/assets/files/random/animals_synonyms.csv',
      'lib/assets/files/random/plants_synonyms.csv'
    )
    Rake::Task["import:standard_references"].invoke
    Sapi::fix_listing_changes()
    Sapi::rebuild()
  end

  desc 'Runs import tasks for the first pages of CITES history (both animals and plants)'
  task :first_pages_cites => :environment do
    Rake::Task["db:seed"].invoke
    Rake::Task["import:species"].invoke(
      'lib/assets/files/first_pages_cites/animals_taxon_concepts.csv',
      'lib/assets/files/first_pages_cites/plants_taxon_concepts.csv'
    )
    Rake::Task["import:cites_regions"].invoke(
      'lib/assets/files/cites_regions.csv'
    )
    Rake::Task["import:countries"].invoke(
      'lib/assets/files/countries.csv'
    )
    Rake::Task["import:distributions"].invoke(
      'lib/assets/files/first_pages_cites/animals_distributions.csv',
      'lib/assets/files/first_pages_cites/plants_distributions.csv'
    )
    Rake::Task["import:cites_listings"].invoke(
      'lib/assets/files/first_pages_cites/animals_listing_changes.csv',
      'lib/assets/files/first_pages_cites/plants_listing_changes.csv'
    )
    Rake::Task["import:common_names"].invoke(
      'lib/assets/files/first_pages_cites/animals_common_names.csv',
      'lib/assets/files/first_pages_cites/plants_common_names.csv'
    )
    Rake::Task["import:synonyms"].invoke(
      'lib/assets/files/first_pages_cites/animals_synonyms.csv',
      'lib/assets/files/first_pages_cites/plants_synonyms.csv'
    )
    Sapi::fix_listing_changes()
    Sapi::rebuild()
  end

  desc 'Runs import tasks for the first pages of CITES animals history + non listed species'
  task :first_pages_cites_with_nc => :environment do
    Rake::Task["db:seed"].invoke
    Rake::Task["import:species"].invoke(
      'lib/assets/files/first_pages_cites_with_nc/animals_taxon_concepts.csv'
    )
    Rake::Task["import:cites_regions"].invoke(
      'lib/assets/files/cites_regions.csv'
    )
    Rake::Task["import:countries"].invoke(
      'lib/assets/files/countries.csv'
    )
    Rake::Task["import:distributions"].invoke(
      'lib/assets/files/first_pages_cites_with_nc//animals_distributions.csv'
    )
    Rake::Task["import:cites_listings"].invoke(
      'lib/assets/files/first_pages_cites_with_nc//animals_listing_changes.csv'
    )
    Rake::Task["import:common_names"].invoke(
      'lib/assets/files/first_pages_cites_with_nc//animals_common_names.csv'
    )
    Sapi::fix_listing_changes()
    Sapi::rebuild()
  end

end
