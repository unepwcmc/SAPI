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
  def self.fix_listing_changes
    ActiveRecord::Base.connection.execute('SELECT * FROM fix_cites_listing_changes()')
  end

  def self.drop_indices
    ActiveRecord::Base.connection.execute('DROP INDEX IF EXISTS index_taxon_concepts_on_data')
    ActiveRecord::Base.connection.execute('DROP INDEX IF EXISTS index_taxon_concepts_on_lft')
  end

  def self.create_indices
    ActiveRecord::Base.connection.execute('CREATE INDEX index_taxon_concepts_on_data ON taxon_concepts USING btree (data)')
    ActiveRecord::Base.connection.execute('CREATE INDEX index_taxon_concepts_on_lft ON taxon_concepts USING btree (lft)')
  end

end