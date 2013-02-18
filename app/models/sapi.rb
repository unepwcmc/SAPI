module Sapi

  REBUILD_PROCEDURES = [
    :names_and_ranks,
    :taxonomic_positions,
    :cites_status,
    :fully_covered_flags,
    :cites_nc_flags,
    :listings,
    :descendant_listings,
    :ancestor_listings,
    :cites_accepted_flags,
    :cites_show_flags,
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
  ]

  def self.rebuild(options = {})
    procedures = REBUILD_PROCEDURES - (options[:except] || [])
    procedures &= options[:only] unless options[:only].nil?
    procedures.each{ |p| ActiveRecord::Base.connection.execute("SELECT * FROM rebuild_#{p}()") }
  end

  def self.rebuild_taxonomy
    rebuild(:only => [:names_and_ranks, :taxonomic_positions])
  end

  def self.rebuild_listings
    rebuild(:only => [
      :cites_listed_flags,
      :listings,
      :descendant_listings,
      :ancestor_listings
    ])
  end

  def self.rebuild_references
    rebuild(:only => [:cites_accepted_flags])
  end

  def self.rebuild_taxon_concepts_mview
    rebuild(:only => [:taxon_concepts_mview])
  end

  def self.rebuild_listing_changes_mview
    rebuild(:only => [:listing_changes_mview])
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

  def self.drop_indices
    indices = %w(
      index_taxon_concepts_on_lft
      index_taxon_concepts_on_parent_id
      index_taxon_concepts_mview_on_parent_id
      index_taxon_concepts_mview_on_full_name
      index_taxon_concepts_mview_on_history_filter
      index_listing_changes_on_annotation_id
      index_listing_changes_on_hash_annotation_id
      index_listing_changes_on_parent_id
      index_listing_changes_mview_on_taxon_concept_id
      index_listing_distributions_on_geo_entity_id
      index_listing_distributions_on_listing_change_id
    )
    indices.each { |i| ActiveRecord::Base.connection.execute("DROP INDEX IF EXISTS #{i}") }
  end

  def self.create_indices
    ActiveRecord::Base.connection.execute('CREATE INDEX index_taxon_concepts_on_lft ON taxon_concepts USING btree (lft)')
    ActiveRecord::Base.connection.execute('CREATE INDEX index_taxon_concepts_on_parent_id ON taxon_concepts USING btree (parent_id)')
    ActiveRecord::Base.connection.execute('CREATE INDEX index_taxon_concepts_mview_on_parent_id ON taxon_concepts_mview USING btree (parent_id)')
    ActiveRecord::Base.connection.execute('CREATE INDEX index_taxon_concepts_mview_on_full_name ON taxon_concepts_mview USING btree (full_name)')
    ActiveRecord::Base.connection.execute('CREATE INDEX index_taxon_concepts_mview_on_history_filter ON taxon_concepts_mview USING btree (taxonomy_is_cites_eu, cites_listed, kingdom_position)')
    ActiveRecord::Base.connection.execute('CREATE INDEX index_listing_changes_on_annotation_id ON listing_changes USING btree (annotation_id)')
    ActiveRecord::Base.connection.execute('CREATE INDEX index_listing_changes_on_hash_annotation_id ON listing_changes USING btree (hash_annotation_id)')
    ActiveRecord::Base.connection.execute('CREATE INDEX index_listing_changes_on_parent_id ON listing_changes USING btree (parent_id)')
    ActiveRecord::Base.connection.execute('CREATE INDEX index_listing_changes_mview_on_taxon_concept_id ON listing_changes_mview USING btree (taxon_concept_id)')
    ActiveRecord::Base.connection.execute('CREATE INDEX index_listing_distributions_on_geo_entity_id ON listing_distributions USING btree (geo_entity_id)')
    ActiveRecord::Base.connection.execute('CREATE INDEX index_listing_distributions_on_listing_change_id ON listing_distributions USING btree (listing_change_id)')
  end

end
