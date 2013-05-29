namespace :import do

  desc 'Runs import tasks for cleaned files'
  task :cleaned => :environment do
    Sapi::drop_indices
    Sapi::disable_triggers
    Rake::Task["db:seed"].invoke
    Rake::Task["import:species"].invoke(
      'lib/assets/files/cleaned/animals/animalia_taxa_utf8.csv',
      'lib/assets/files/cleaned/plants/plantae_taxa_utf8.csv'
    )
    Rake::Task["import:cites_regions"].invoke(
      'lib/assets/files/cites_regions.csv'
    )
    Rake::Task["import:countries"].invoke(
      'lib/assets/files/cleaned/countries_utf8.csv'
    )
    Rake::Task["import:languages"].invoke(
      'lib/assets/files/cleaned/languages_utf8.csv'
    )
    Rake::Task["import:distributions"].invoke(
      'lib/assets/files/cleaned/animals/animalia_distribution_utf8.csv',
      'lib/assets/files/cleaned/plants/plantae_distribution_utf8.csv'
    )
    Rake::Task["import:distribution_tags"].invoke(
      'lib/assets/files/cleaned/animals/animalia_distribution_tags_utf8.csv',
      'lib/assets/files/cleaned/plants/plantae_distribution_tags_utf8.csv'
    )
    Rake::Task["import:cites_listings"].invoke(
      'lib/assets/files/cleaned/animals/animalia_legislation_utf8.csv',
      'lib/assets/files/cleaned/plants/plantae_legislation_utf8.csv'
    )
    Rake::Task["import:common_names"].invoke(
      'lib/assets/files/cleaned/animals/animalia_common_names_utf8.csv',
      'lib/assets/files/cleaned/plants/plantae_common_names_utf8.csv'
    )
    Rake::Task["import:synonyms"].invoke(
      'lib/assets/files/cleaned/animals/animalia_synonyms_utf8.csv',
      'lib/assets/files/cleaned/plants/plantae_synonyms_utf8.csv'
    )
    Rake::Task["import:references"].invoke(
     'lib/assets/files/cleaned/animals/animalia_references_utf8.csv',
     'lib/assets/files/cleaned/plants/plantae_references_utf8.csv'
    )
    Rake::Task["import:reference_distribution_links"].invoke(
     'lib/assets/files/cleaned/animals/animalia_reference_distribution_links.csv',
     'lib/assets/files/cleaned/plants/plantae_reference_distribution_links.csv'
    )
    Rake::Task["import:reference_accepted_links"].invoke(
     'lib/assets/files/cleaned/animals/animalia_reference_accepted_links.csv',
     'lib/assets/files/cleaned/plants/plantae_reference_accepted_links.csv'
    )
    Rake::Task["import:reference_synonym_links"].invoke(
     'lib/assets/files/cleaned/animals/animalia_reference_synonym_links.csv',
     'lib/assets/files/cleaned/plants/plantae_reference_synonym_links.csv'
    )
    Rake::Task["import:standard_reference_links"].invoke(
     'lib/assets/files/cleaned/animals/animalia_standard_reference_links.csv',
     'lib/assets/files/cleaned/plants/plantae_standard_reference_links.csv'
    )
    Rake::Task["import:laws"].invoke(
      'lib/assets/files/laws.csv'
    )

    Rake::Task["import:cites_quotas"].invoke(
      'lib/assets/files/cleaned/quotas_utf8.csv'
    )

    Rake::Task["import:cites_suspensions"].invoke(
      'lib/assets/files/cleaned/cites_suspensions_utf8.csv'
    )

    Rake::Task["import:trade_codes"].invoke

    Sapi::rebuild()
    Sapi::enable_triggers
    Sapi::create_indices

    Rake::Task['import:stats'].invoke
  end

  desc 'Drops and reimports db'
  task :redo => ["db:drop", "db:create", "db:migrate", "db:seed", "import:cleaned"]

  desc 'Shows database summary stats'
  task :stats => :environment do
    Sapi::database_summary
  end

end
