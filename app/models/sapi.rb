module Sapi
  def self.rebuild
    ActiveRecord::Base.connection.execute('SELECT * FROM sapi_rebuild()')
    ActiveRecord::Base.connection.execute('SELECT * FROM rebuild_mviews()')
  end
  def self.rebuild_taxonomy
    ActiveRecord::Base.connection.execute('SELECT * FROM rebuild_names_and_ranks()')
    ActiveRecord::Base.connection.execute('SELECT * FROM rebuild_taxonomic_positions()')
  end
  def self.rebuild_listings
    ActiveRecord::Base.connection.execute('SELECT * FROM rebuild_cites_listed_flags()')
    ActiveRecord::Base.connection.execute('SELECT * FROM rebuild_listings()')
    ActiveRecord::Base.connection.execute('SELECT * FROM rebuild_descendant_listings()')
    ActiveRecord::Base.connection.execute('SELECT * FROM rebuild_ancestor_listings()')
  end
  def self.rebuild_references
    ActiveRecord::Base.connection.execute('SELECT * FROM rebuild_cites_accepted_flags()')
  end

  def self.disable_triggers
    ActiveRecord::Base.connection.execute("ALTER TABLE taxon_concepts DISABLE TRIGGER ALL")
  end

  def self.enable_triggers
    ActiveRecord::Base.connection.execute("ALTER TABLE taxon_concepts ENABLE TRIGGER ALL")
  end

  def self.drop_indices
    indices = %w(
      index_taxon_concepts_on_lft
      index_taxon_concepts_on_parent_id
      index_taxon_concepts_mview_on_parent_id
      index_taxon_concepts_mview_on_full_name
      index_taxon_concepts_mview_on_history_filter
      index_listing_changes_on_annotation_id
      index_listing_changes_on_parent_id
      index_listing_changes_mview_on_taxon_concept_id
      index_annotations_on_listing_change_id
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
    ActiveRecord::Base.connection.execute('CREATE INDEX index_taxon_concepts_mview_on_history_filter ON taxon_concepts_mview USING btree (designation_is_cites, cites_listed, kingdom_position)')
    ActiveRecord::Base.connection.execute('CREATE INDEX index_listing_changes_on_annotation_id ON listing_changes USING btree (annotation_id)')
    ActiveRecord::Base.connection.execute('CREATE INDEX index_listing_changes_on_parent_id ON listing_changes USING btree (parent_id)')
    ActiveRecord::Base.connection.execute('CREATE INDEX index_listing_changes_mview_on_taxon_concept_id ON listing_changes_mview USING btree (taxon_concept_id)')
    ActiveRecord::Base.connection.execute('CREATE INDEX index_annotations_on_listing_change_id ON annotations USING btree (listing_change_id)')
    ActiveRecord::Base.connection.execute('CREATE INDEX index_listing_distributions_on_geo_entity_id ON listing_distributions USING btree (geo_entity_id)')
    ActiveRecord::Base.connection.execute('CREATE INDEX index_listing_distributions_on_listing_change_id ON listing_distributions USING btree (listing_change_id)')
  end

  def self.rebuild_taxon_concepts_mview
    ActiveRecord::Base.connection.execute "DROP TABLE IF EXISTS taxon_concepts_mview"
    ActiveRecord::Base.connection.execute <<-SQL
    CREATE TABLE taxon_concepts_mview AS
    SELECT *,
    false as dirty,
    null::timestamp with time zone as expiry
    FROM taxon_concepts_view;
    SQL
    ActiveRecord::Base.connection.execute('CREATE UNIQUE INDEX taxon_concepts_mview_on_id ON taxon_concepts_mview (id)')
  end

  def self.rebuild_listing_changes_mview
    ActiveRecord::Base.connection.execute "DROP TABLE IF EXISTS listing_changes_mview"
    ActiveRecord::Base.connection.execute <<-SQL
    CREATE TABLE listing_changes_mview AS
    SELECT *,
    false as dirty,
    null::timestamp with time zone as expiry
    FROM listing_changes_view;
    SQL
    ActiveRecord::Base.connection.execute('CREATE UNIQUE INDEX listing_changes_mview_on_id ON listing_changes_mview (id)')
  end

  def self.rebuild_mviews
    rebuild_taxon_concepts_mview
    rebuild_listing_changes_mview
  end

end