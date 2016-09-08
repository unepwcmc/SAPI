namespace :import do

  task :drop_import_tables => :environment do
    ActiveRecord::Base.connection.execute 'SELECT * FROM drop_import_tables()'
  end

  namespace :cleaned do
    task :species => :environment do
      Rake::Task["import:species"].invoke(
        'lib/files/animals/animalia_taxa_utf8.csv',
        'lib/files/plants/plantae_taxa_utf8.csv'
      )
    end
    task :geo_entities => :environment do
      Rake::Task["import:cites_regions"].invoke(
        'lib/files/cites_regions_utf8.csv'
      )
      Rake::Task["import:countries"].invoke(
        'lib/files/countries_utf8.csv'
      )
      Rake::Task["import:cites_parties"].invoke
    end
    task :languages => :environment do
      Rake::Task["import:languages"].invoke(
        'lib/files/languages_utf8.csv'
      )
    end
    task :events => :environment do
      Rake::Task["import:events"].invoke(
        'lib/files/events_utf8.csv'
      )
    end
    task :distributions => :environment do
      Rake::Task["import:distributions"].invoke(
        'lib/files/animals/animalia_distribution_utf8.csv',
        'lib/files/plants/plantae_distribution_utf8.csv'
      )
      Rake::Task["import:distribution_tags"].invoke(
        'lib/files/animals/animalia_distribution_tags_utf8.csv',
        'lib/files/plants/plantae_distribution_tags_utf8.csv'
      )
    end

    task :listings => :environment do
      Rake::Task["import:hash_annotations"].invoke(
        'lib/files/hash_annotations_eu_utf8.csv',
        'lib/files/hash_annotations_cites_utf8.csv'
      )
      Rake::Task["import:cites_listings"].invoke(
        'lib/files/animals/animalia_legislation_utf8.csv',
        'lib/files/plants/plantae_legislation_utf8.csv'
      )
      Rake::Task["import:eu_listings"].invoke(
        'lib/files/animals/animalia_eu_legislation_utf8.csv',
        'lib/files/plants/plantae_eu_legislation_utf8.csv'
      )
      Rake::Task["import:cms_listings"].invoke(
        'lib/files/animals/CMS_legislation_utf8.csv'
      )
    end

    task :common_names => :environment do
      Rake::Task["import:common_names"].invoke(
        'lib/files/animals/animalia_common_names_utf8.csv',
        'lib/files/plants/plantae_common_names_utf8.csv'
      )
    end

    task :synonyms => :environment do
      Rake::Task["import:synonyms"].invoke(
        'lib/files/animals/animalia_synonyms_utf8.csv',
        'lib/files/plants/plantae_synonyms_utf8.csv'
      )
    end

    task :references => :environment do
      Rake::Task["import:references"].invoke(
        'lib/files/animals/animalia_references_utf8.csv',
        'lib/files/plants/plantae_references_utf8.csv'
      )
      Rake::Task["import:reference_distribution_links"].invoke(
        'lib/files/animals/animalia_reference_distribution_links_utf8.csv',
        'lib/files/plants/plantae_reference_distribution_links_utf8.csv'
      )
      Rake::Task["import:reference_accepted_links"].invoke(
        'lib/files/animals/animalia_reference_accepted_links_utf8.csv',
        'lib/files/plants/plantae_reference_accepted_links_utf8.csv'
      )
      Rake::Task["import:reference_synonym_links"].invoke(
        'lib/files/animals/animalia_reference_synonym_links_utf8.csv',
        'lib/files/plants/plantae_reference_synonym_links_utf8.csv'
      )
      Rake::Task["import:standard_reference_links"].invoke(
        'lib/files/animals/animalia_standard_reference_links_utf8.csv',
        'lib/files/animals/CMS_standard_reference_links_utf8.csv',
        'lib/files/plants/plantae_standard_reference_links_utf8.csv'
      )
    end

    task :cites_quotas => :environment do
      Rake::Task["import:cites_quotas"].invoke(
        'lib/files/quotas_utf8.csv'
      )
    end

    task :cites_suspensions => :environment do
      Rake::Task["import:cites_suspensions"].invoke(
        'lib/files/cites_suspensions_utf8.csv'
      )
    end

    task :eu_decisions => :environment do
      Rake::Task["import:eu_decisions"].invoke(
        'lib/files/eu_decisions_utf8.csv'
      )
    end
  end

  desc 'Shows database summary stats'
  task :stats => :environment do
    Sapi::database_summary
  end

  desc 'Runs import tasks for cleaned files'
  task :cleaned => [
    :environment,
    :"db:migrate:drop_indexes",
    :"cleaned:species", :"cleaned:geo_entities", :"cleaned:languages",
    :"cleaned:events", :"cleaned:distributions", :"cleaned:listings",
    :"cleaned:common_names", :"cleaned:synonyms", :"cleaned:references",
    :"import:trade_codes", :"import:trade_codes_t_p_pairs", :"import:trade_codes_t_u_pairs",
    :"cleaned:cites_quotas", :"cleaned:cites_suspensions", :"cleaned:cites_quotas",
    :"import:eu_annex_regulations_end_dates",
    :"import:ranks_translations", :"import:change_types_translations", :"import:fix_symbols",
    :"db:migrate:create_indexes",
    :"db:migrate:rebuild",
    :"import:stats"
  ]

  desc 'Runs trade import support tasks (unnusual_geo_entities, trade_species_mapping, trade_names, synonyms_to_trade_names)'
  task :trade_support => [
    :"import:unusual_geo_entities",
    :"import:trade_species_mapping",
    :"import:trade_names",
    :"import:synonyms_to_trade_names"
  ]

  desc 'Runs import tasks for all the trade related tasks'
  # SHIPMENTS_FILE=path/to/file PERMITS_FILE=path/to/file rake import:trade
  task :trade => [:"import:trade_support"] do
    Rake::Task["import:shipments"].invoke(
      ENV['SHIPMENTS_FILE']
    )
    Rake::Task["import:trade_permits"].invoke(
      ENV['PERMITS_FILE']
    )
  end

  desc 'Drops and reimports db'
  task :redo => ["db:drop", "db:create", "db:migrate", "db:seed", "import:cleaned", "downloads:cache:clear"]

end
