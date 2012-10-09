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

  def self.drop_indices
    ActiveRecord::Base.connection.execute('DROP INDEX IF EXISTS index_taxon_concepts_on_data')
    ActiveRecord::Base.connection.execute('DROP INDEX IF EXISTS index_taxon_concepts_on_lft')
  end

  def self.create_indices
    ActiveRecord::Base.connection.execute('CREATE INDEX index_taxon_concepts_on_data ON taxon_concepts USING btree (data)')
    ActiveRecord::Base.connection.execute('CREATE INDEX index_taxon_concepts_on_lft ON taxon_concepts USING btree (lft)')
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