namespace :import do

  desc 'Runs import tasks for cleaned files'
  task :cleaned => :environment do
    Sapi::drop_indexes
    Sapi::disable_triggers
    Rake::Task["db:seed"].invoke
    Rake::Task["import:species"].invoke(
      'lib/assets/files/animals/animalia_taxa_utf8.csv',
      'lib/assets/files/plants/plantae_taxa_utf8.csv'
    )
    Rake::Task["import:cites_regions"].invoke(
      'lib/assets/files/cites_regions.csv'
    )
    Rake::Task["import:countries"].invoke(
      'lib/assets/files/countries_utf8.csv'
    )
    Rake::Task["import:languages"].invoke(
      'lib/assets/files/languages_utf8.csv'
    )
    Rake::Task["import:cites_parties"].invoke

    Rake::Task["import:events"].invoke(
      'lib/assets/files/events_utf8.csv'
    )
    Rake::Task["import:hash_annotations"].invoke(
      'lib/assets/files/hash_annotations_eu_utf8.csv',
      'lib/assets/files/hash_annotations_cites_utf8.csv'
    )

    Rake::Task["import:distributions"].invoke(
      'lib/assets/files/animals/animalia_distribution_utf8.csv',
      'lib/assets/files/plants/plantae_distribution_utf8.csv'
    )
    Rake::Task["import:distribution_tags"].invoke(
      'lib/assets/files/animals/animalia_distribution_tags_utf8.csv',
      'lib/assets/files/plants/plantae_distribution_tags_utf8.csv'
    )
    Rake::Task["import:cites_listings"].invoke(
      'lib/assets/files/animals/animalia_legislation_utf8.csv',
      'lib/assets/files/plants/plantae_legislation_utf8.csv'
    )
    Rake::Task["import:eu_listings"].invoke(
      'lib/assets/files/animals/animalia_eu_legislation_utf8.csv',
      'lib/assets/files/plants/plantae_eu_legislation_utf8.csv'
    )
    Rake::Task["import:cms_listings"].invoke(
      'lib/assets/files/animals/CMS_legislation_utf8.csv'
    )
    Rake::Task["import:common_names"].invoke(
      'lib/assets/files/animals/animalia_common_names_utf8.csv',
      'lib/assets/files/plants/plantae_common_names_utf8.csv'
    )
    Rake::Task["import:synonyms"].invoke(
      'lib/assets/files/animals/animalia_synonyms_utf8.csv',
      'lib/assets/files/plants/plantae_synonyms_utf8.csv'
    )
    Rake::Task["import:references"].invoke(
     'lib/assets/files/animals/animalia_references_utf8.csv',
     'lib/assets/files/plants/plantae_references_utf8.csv'
    )
    Rake::Task["import:reference_distribution_links"].invoke(
     'lib/assets/files/animals/animalia_reference_distribution_links_utf8.csv',
     'lib/assets/files/plants/plantae_reference_distribution_links_utf8.csv'
    )
    Rake::Task["import:reference_accepted_links"].invoke(
     'lib/assets/files/animals/animalia_reference_accepted_links_utf8.csv',
     'lib/assets/files/plants/plantae_reference_accepted_links_utf8.csv'
    )
    Rake::Task["import:reference_synonym_links"].invoke(
     'lib/assets/files/animals/animalia_reference_synonym_links_utf8.csv',
     'lib/assets/files/plants/plantae_reference_synonym_links_utf8.csv'
    )
    Rake::Task["import:standard_reference_links"].invoke(
     'lib/assets/files/animals/animalia_standard_reference_links_utf8.csv',
     'lib/assets/files/animals/CMS_standard_reference_links_utf8.csv',
     'lib/assets/files/plants/plantae_standard_reference_links_utf8.csv'
    )

    Rake::Task["import:trade_codes"].invoke

    Rake::Task["import:cites_quotas"].invoke(
      'lib/assets/files/quotas_utf8.csv'
    )

    Rake::Task["import:cites_suspensions"].invoke(
      'lib/assets/files/cites_suspensions_utf8.csv'
    )

    Rake::Task["import:eu_decisions"].invoke(
      'lib/assets/files/eu_decisions_utf8.csv'
    )

    Rake::Task["import:fix_symbols"].invoke

    Sapi::create_indexes
    Sapi::rebuild(:disable_triggers => true)

    Sapi::enable_triggers

    Rake::Task['import:stats'].invoke
  end

  desc 'Drops and reimports db'
  task :redo => ["db:drop", "db:create", "db:migrate", "import:cleaned"]

  desc 'Shows database summary stats'
  task :stats => :environment do
    Sapi::database_summary
  end

end
