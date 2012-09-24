namespace :import do
  desc 'Runs import tasks for all taxa in the CITES checklist'
  task :all => :environment do
    Sapi::drop_indices
    Rake::Task["db:seed"].invoke
    Rake::Task["import:species"].invoke(
      'lib/assets/files/all/animals_taxon_concepts.csv',
      'lib/assets/files/all/plants_taxon_concepts.csv'
    )
    puts "rebuilding the nested set" #TODO remove depth calculations
    #rebuild the tree
    TaxonConcept.rebuild!
    #set the depth on all nodes
    TaxonConcept.roots.each do |root|
      TaxonConcept.each_with_level(root.self_and_descendants) do |node, level|
        node.send(:"set_depth!")
      end
    end
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
    Sapi::fix_listing_changes()
    Sapi::rebuild()
    Sapi::create_indices
  end

  desc 'Runs import tasks for a random subset of CITES checklist (both animals and plants)'
  task :random => :environment do
    Sapi::drop_indices
    Rake::Task["db:seed"].invoke
    Rake::Task["import:species"].invoke(
      'lib/assets/files/random/animals.csv',
      'lib/assets/files/random/plants.csv'
    )
    puts "rebuilding the nested set" #TODO remove depth calculations
    #rebuild the tree
    TaxonConcept.rebuild!
    #set the depth on all nodes
    TaxonConcept.roots.each do |root|
      TaxonConcept.each_with_level(root.self_and_descendants) do |node, level|
        node.send(:"set_depth!")
      end
    end
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
      'lib/assets/files/random/animals_listing_changes.csv'#TODO missing listing changes for plants
    )
    Rake::Task["import:common_names"].invoke(
      'lib/assets/files/random/animals_common_names.csv',
      'lib/assets/files/random/plants_common_names.csv'
    )
    Rake::Task["import:synonyms"].invoke(
      'lib/assets/files/random/animals_synonyms.csv',
      'lib/assets/files/random/plants_synonyms.csv'
    )
    Sapi::fix_listing_changes()
    Sapi::rebuild()
    Sapi::create_indices
  end

  desc 'Runs import tasks for the first pages of CITES history (both animals and plants)'
  task :first_pages_cites => :environment do
    Sapi::drop_indices
    Rake::Task["db:seed"].invoke
    Rake::Task["import:species"].invoke(
      'lib/assets/files/first_pages_cites/animals_taxon_concepts.csv',
      'lib/assets/files/first_pages_cites/plants_taxon_concepts.csv'
    )
    puts "rebuilding the nested set" #TODO remove depth calculations
    #rebuild the tree
    TaxonConcept.rebuild!
    #set the depth on all nodes
    TaxonConcept.roots.each do |root|
      TaxonConcept.each_with_level(root.self_and_descendants) do |node, level|
        node.send(:"set_depth!")
      end
    end
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
    Rake::Task["import:references"].invoke(
      'lib/assets/files/references.csv'
    )
    Rake::Task["import:reference_links"].invoke(
      'lib/assets/files/animals_reference_links.csv',
      'lib/assets/files/plants_reference_links.csv'
    )
    Rake::Task["import:standard_references"].invoke(
      'lib/assets/files/standard_references.csv'
    )
    Sapi::fix_listing_changes()
    Sapi::rebuild()
    Sapi::create_indices
  end

end
