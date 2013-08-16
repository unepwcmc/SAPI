module Sapi
  module Indexes

    # rewrite the code below to just use add_index and add UNIQUE to the mview ids
    # add_index "listing_changes_mview", ["id"], :name => "listing_changes_mview_on_id", :unique => true

    INDEXES = [
      {
        :name => 'index_taxon_concepts_on_parent_id',
        :on => 'taxon_concepts (parent_id)'
      },
      {
        :name => 'index_taxon_concepts_on_full_name',
        :on => 'taxon_concepts USING BTREE(UPPER(full_name) text_pattern_ops)'
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
        :name => 'index_listing_distributions_on_geo_entity_id',
        :on => 'listing_distributions (geo_entity_id)'
      },
      {
        :name => 'index_listing_distributions_on_listing_change_id',
        :on => 'listing_distributions (listing_change_id)'
      }
    ]

    def self.drop_indexes
      INDEXES.each do |i|
        ActiveRecord::Base.connection.execute("DROP INDEX IF EXISTS #{i[:name]}")
      end
    end

    def self.create_indexes
      INDEXES.each do |i|
        ActiveRecord::Base.connection.execute("CREATE INDEX #{i[:name]} ON #{i[:on]}")
      end
    end

  end
end