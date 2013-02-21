namespace :import do
  desc 'Runs import tasks for all taxa in the CITES checklist'
  task :all => :environment do
    Sapi::drop_indices
    Sapi::disable_triggers
    Rake::Task["db:seed"].invoke
    Rake::Task["import:species"].invoke(
      'lib/assets/files/all/animals_taxon_concepts.csv',
      'lib/assets/files/all/plants_taxon_concepts.csv'
    )
    puts "rebuilding the nested set"
    #rebuild the tree
    TaxonConcept.rebuild!

    Rake::Task["import:cites_regions"].invoke(
      'lib/assets/files/cites_regions.csv'
    )
    Rake::Task["import:countries"].invoke(
      'lib/assets/files/countries.csv'
    )
    Rake::Task["import:distributions"].invoke(
      'lib/assets/files/all/animals_distributions.csv',
      'lib/assets/files/all/plants_distributions.csv'
    )
    Rake::Task["import:cites_listings"].invoke(
      'lib/assets/files/all/animals_listing_changes.csv',
      'lib/assets/files/all/plants_listing_changes.csv'
    )
    Rake::Task["import:common_names"].invoke(
      'lib/assets/files/all/animals_common_names.csv',
      'lib/assets/files/all/plants_common_names.csv'
    )
    Rake::Task["import:synonyms"].invoke(
      'lib/assets/files/all/animals_synonyms.csv',
      'lib/assets/files/all/plants_synonyms.csv'
    )
    Rake::Task["import:references"].invoke(
      'lib/assets/files/references.csv'
    )
    Rake::Task["import:standard_references"].invoke(
      'lib/assets/files/standard_references.csv'
    )

    Sapi::rebuild()
    Sapi::enable_triggers
    Sapi::create_indices
  end

  desc 'Runs import tasks for the first pages of CITES history (both animals and plants)'
  task :first_pages_cites => :environment do
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
    Rake::Task["import:distributions"].invoke(
      'lib/assets/files/cleaned/animals/animalia_distribution_utf8.csv',
      'lib/assets/files/cleaned/plants/plantae_distribution_utf8.csv'
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
     #Rake::Task["import:references"].invoke(
     #  'lib/assets/files/references.csv'
     #)
#    Rake::Task["import:reference_links"].invoke(
#      'lib/assets/files/animals_reference_links.csv',
#      'lib/assets/files/plants_reference_links.csv'
#    )
   Rake::Task["import:standard_references"].invoke(
     'lib/assets/files/cleaned/animals/animalia_standard_refs_utf8.csv',
     'lib/assets/files/cleaned/plants/plantae_standard_refs_utf8.csv'
   )
#
    Rake::Task["import:trade_codes"].invoke

    Sapi::rebuild()
    puts "rebuilding the nested set"
    #rebuild the tree
    TaxonConcept.rebuild!
    Sapi::enable_triggers
    Sapi::create_indices
  end

  desc 'Drops and reimports db'
  task :redo => ["db:drop", "db:create", "db:migrate", "db:seed", "import:first_pages_cites"]
end
