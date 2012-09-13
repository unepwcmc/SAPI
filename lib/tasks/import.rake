namespace :import do
  task :all => "import:random" do; end

  desc 'Runs import tasks for a random subset of CITES checklist (both animals and plants)'
  task :random => :environment do
    Sapi::drop_indices
    Rake::Task["db:seed"].invoke
    Rake::Task["import:species"].invoke
    Rake::Task["import:synonyms"].invoke
    Rake::Task["import:cites_regions"].invoke(
      'lib/assets/files/cites_regions.csv'
    )
    Rake::Task["import:countries"].invoke(
      'lib/assets/files/countries.csv'
    )
    Rake::Task["import:distributions"].invoke
    Rake::Task["import:cites_listings"].invoke
    Rake::Task["import:common_names"].invoke
    Rake::Task["import:references"].invoke
    Rake::Task["import:reference_links"].invoke
    Rake::Task["import:standard_references"].invoke(
      'lib/assets/standard_nomenclature.csv'
    )
    Sapi::rebuild_taxonomy()
    Sapi::create_indices
  end

  desc 'Runs import tasks for the first pages of CITES history (both animals and plants)'
  task :first_pages_cites => :environment do
    Sapi::drop_indices
    Rake::Task["db:seed"].invoke
    Rake::Task["import:species"].invoke
    Rake::Task["import:synonyms"].invoke
    Rake::Task["import:cites_regions"].invoke(
      'lib/assets/files/cites_regions.csv'
    )
    Rake::Task["import:countries"].invoke(
      'lib/assets/files/countries.csv'
    )
    Rake::Task["import:distributions"].invoke
    Rake::Task["import:cites_listings"].invoke
    Rake::Task["import:common_names"].invoke
    Sapi::rebuild_taxonomy()
    Sapi::create_indices
  end

  desc 'Runs import tasks for the first pages of CITES animals history + non listed species'
  task :first_pages_cites_with_nc => :environment do
    Sapi::drop_indices
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
    Sapi::rebuild_taxonomy()
    Sapi::create_indices
  end

end
