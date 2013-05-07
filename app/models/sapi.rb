module Sapi

  REBUILD_PROCEDURES = [
    :taxonomy,
    :cites_listing,
    :eu_listing,
    :cites_accepted_flags,
    :taxon_concepts_mview,
    :listing_changes_mview
  ]

  TABLES_WITH_TRIGGERS = [
    :taxon_concepts,
    :ranks,
    :taxon_names,
    :common_names,
    :taxon_commons,
    :taxon_relationships,
    :geo_entities,
    :distributions,
    :taxon_concept_references,
    :listing_changes,
    :annotations,
    :change_types,
    :species_listings,
    :listing_distributions
  ]

  def self.rebuild(options = {})
    self.disable_triggers if options[:disable_triggers]
    procedures = REBUILD_PROCEDURES - (options[:except] || [])
    procedures &= options[:only] unless options[:only].nil?
    procedures.each{ |p|
      puts "Starting procedure: #{p}"
      ActiveRecord::Base.connection.execute("SELECT * FROM rebuild_#{p}()")
      puts "Ending procedure: #{p}"
    }
    self.enable_triggers if options[:disable_triggers]
  end

  def self.rebuild_taxonomy
    rebuild(:only => [:taxonomy])
  end

  def self.rebuild_listings
    rebuild(:only => [:cites_listing, :eu_listing])
  end

  def self.rebuild_references
    rebuild(:only => [:cites_accepted_flags])
  end

  def self.rebuild_taxon_concepts_mview
    rebuild(:only => [:taxon_concepts_mview], :disable_triggers => false)
  end

  def self.rebuild_listing_changes_mview
    rebuild(:only => [:listing_changes_mview], :disable_triggers => false)
  end

  def self.rebuild_mviews
    rebuild_taxon_concepts_mview
    rebuild_listing_changes_mview
  end

  def self.disable_triggers
    TABLES_WITH_TRIGGERS.each do |table|
      ActiveRecord::Base.connection.execute("ALTER TABLE IF EXISTS #{table} DISABLE TRIGGER ALL")
    end
  end

  def self.enable_triggers
    TABLES_WITH_TRIGGERS.each do |table|
      ActiveRecord::Base.connection.execute("ALTER TABLE IF EXISTS #{table} ENABLE TRIGGER ALL")
    end
  end

  # rewrite the code below to just use add_index and add UNIQUE to the mview ids
  # add_index "listing_changes_mview", ["id"], :name => "listing_changes_mview_on_id", :unique => true

  INDEXES = [
    {
      :name => 'index_taxon_concepts_on_parent_id',
      :on => 'taxon_concepts (parent_id)'
    },
    {
      :name => 'index_taxon_concepts_mview_on_id',
      :on => 'taxon_concepts_mview (id)'
    },
    {
      :name => 'index_taxon_concepts_mview_on_parent_id',
      :on => 'taxon_concepts_mview (parent_id)'
    },
    {
      :name => 'index_taxon_concepts_mview_on_full_name',
      :on => 'taxon_concepts_mview (full_name)'
    },
    {
      :name => 'index_taxon_concepts_mview_on_history_filter',
      :on => 'taxon_concepts_mview (taxonomy_is_cites_eu, cites_listed, kingdom_position)'
    },
    {
      :name => 'index_taxon_concepts_mview_on_cites_closest_listed_ancestor_id',
      :on => 'taxon_concepts_mview (cites_closest_listed_ancestor_id)'
    },
    {
      :name => 'index_taxon_concepts_mview_on_eu_closest_listed_ancestor_id',
      :on => 'taxon_concepts_mview (eu_closest_listed_ancestor_id)'
    },
    {
      :name => 'index_listing_changes_on_annotation_id',
      :on => 'listing_changes (annotation_id)'
    },
    {
      :name => 'index_listing_changes_on_hash_annotation_id',
      :on => 'listing_changes (hash_annotation_id)'
    },
    {
      :name => 'index_listing_changes_on_parent_id',
      :on => 'listing_changes (parent_id)'
    },
    {
      :name => 'index_listing_changes_mview_on_id',
      :on => 'listing_changes_mview (id)'
    },
    {
      :name => 'index_listing_changes_mview_on_taxon_concept_id',
      :on => 'listing_changes_mview (taxon_concept_id)'
    },
    {
      :name => 'index_listing_distributions_on_geo_entity_id',
      :on => 'listing_distributions (geo_entity_id)'
    },
    {
      :name => 'index_listing_distributions_on_listing_change_id',
      :on => 'listing_distributions (listing_change_id)'
    }
  ]

  def self.drop_indices
    INDEXES.each do |i|
      ActiveRecord::Base.connection.execute("DROP INDEX IF EXISTS #{i[:name]}")
    end
  end

  def self.create_indices
    INDEXES.each do |i|
      ActiveRecord::Base.connection.execute("CREATE INDEX #{i[:name]} ON #{i[:on]}")
    end
  end

  def self.database_summary
    puts "#############################################################"
    puts "#################                  ##########################"
    puts "################# Database Summary ##########################"
    puts "#################                  ##########################"
    puts "#############################################################\n"
    Sapi.print_count_for "Taxonomies", Taxonomy.count
    Sapi.print_count_for "Designations", Designation.count
    Sapi.print_count_for "Ranks", Rank.count
    Sapi.print_count_for "TaxonName", TaxonName.count
    Sapi.print_count_for "GeoEntityTypes", GeoEntityType.count
    Sapi.print_count_for "GeoEntities", GeoEntity.count
    Sapi.print_count_for "Countries", GeoEntity.joins(:geo_entity_type).where(:geo_entity_types => {:name => GeoEntityType::COUNTRY}).count
    Sapi.print_count_for "CITES Regions", GeoEntity.joins(:geo_entity_type).where(:geo_entity_types => {:name => GeoEntityType::CITES_REGION}).count
    Sapi.print_count_for "References", Reference.count
    Sapi.print_count_for "CommonNames", CommonName.count
    Sapi.print_count_for "English CommonNames", CommonName.joins(:language).where(:languages => {:name_en => 'English'}).count
    Sapi.print_count_for "French CommonNames", CommonName.joins(:language).where(:languages => {:name_en => 'French'}).count
    Sapi.print_count_for "Spanish CommonNames", CommonName.joins(:language).where(:languages => {:name_en => 'Spanish'}).count
    Sapi.print_count_for "Total TaxonConcepts", TaxonConcept.count
    Taxonomy.where(:name => 'CITES_EU').each do |t|
      puts "#############################################################"
      puts "Details for Taxa under #{t.name}"
      animals_ids = TaxonConcept.where(:taxonomy_id => t.id, :name_status => 'A', :legacy_type => 'Animalia').select('id').map(&:id)
      plants_ids = TaxonConcept.where(:taxonomy_id => t.id, :name_status => 'A', :legacy_type => 'Plantae').select('id').map(&:id)
      puts ">>> Animalia general stats"
      Sapi.print_count_for "accepted", animals_ids.count
      Sapi.print_count_for "non accepted nor synonyms", TaxonConcept.where(:taxonomy_id => t.id, :legacy_type => 'Animalia').where("name_status NOT IN ('A', 'S')").count
      Sapi.print_count_for "Listing Changes", ListingChange.where(:taxon_concept_id => animals_ids).count
      Sapi.print_count_for "Distributions", Distribution.where(:taxon_concept_id => animals_ids).count
      Sapi.print_count_for "TaxonCommons", TaxonCommon.where(:taxon_concept_id => animals_ids).count
      Sapi.print_count_for "Synonyms", TaxonConcept.where(:taxonomy_id => t.id, :name_status => 'S', :legacy_type => 'Animalia').count
      puts ">>> Plantae general stats"
      Sapi.print_count_for "Accepted", plants_ids.count
      Sapi.print_count_for "non accepted nor synonyms", TaxonConcept.where(:taxonomy_id => t.id, :legacy_type => 'Plantae').where("name_status NOT IN ('A', 'S')").count
      Sapi.print_count_for "Listing Changes", ListingChange.where(:taxon_concept_id => plants_ids).count
      Sapi.print_count_for "Distributions", Distribution.where(:taxon_concept_id => plants_ids).count
      Sapi.print_count_for "TaxonCommons", TaxonCommon.where(:taxon_concept_id => plants_ids).count
      Sapi.print_count_for "Synonyms", TaxonConcept.where(:taxonomy_id => t.id, :name_status => 'S', :legacy_type => 'Plantae').count

      puts "###################### #{t.name} ############################"
      puts "Break down per Rank"
      puts "#############################################################"
      Rank.order(:taxonomic_position).each do |r|
        puts "##############   Rank: #{r.name} ####################"
        ranked_animals_ids = TaxonConcept.where(:id => animals_ids, :rank_id => r.id).select(:id).map(&:id)
        ranked_plants_ids = TaxonConcept.where(:id => plants_ids, :rank_id => r.id).select(:id).map(&:id)
        puts ">>> Animalia rank stats"
        Sapi.print_count_for "Taxa", ranked_animals_ids.count
        Sapi.print_count_for " Listing Changes", ListingChange.where(:taxon_concept_id => ranked_animals_ids).count
        puts ">>> Plantae rank stats"
        Sapi.print_count_for "Taxa", ranked_plants_ids.count
        Sapi.print_count_for "Listing Changes", ListingChange.where(:taxon_concept_id => ranked_plants_ids).count
        puts "#####################################################"
      end
    end
  end

  def self.print_count_for klass, count
    puts "#{count} #{klass} in the Database. #{if count == 0 then " !!!!!!!!!!!!!!!!!!!!!!! ZERO !!!!!!!!!!!!!!!!!!!!!!! " end}"
  end
end
