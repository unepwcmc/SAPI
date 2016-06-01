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
        :name => 'index_taxon_concepts_on_full_name_prefix',
        :on => 'taxon_concepts USING BTREE(UPPER(full_name) text_pattern_ops)'
      },
      {
        :name => 'index_taxon_concepts_on_full_name',
        :on => 'taxon_concepts (full_name)'
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
        :name => 'index_listing_changes_on_taxon_concept_id',
        :on => 'listing_changes (taxon_concept_id)'
      },
      {
        :name => 'index_listing_changes_on_inclusion_taxon_concept_id',
        :on => 'listing_changes (inclusion_taxon_concept_id)'
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

    def self.drop_indexes_on_shipments
      sql = <<-SQL
      DROP INDEX IF EXISTS index_trade_shipments_on_appendix;
      DROP INDEX IF EXISTS index_trade_shipments_on_country_of_origin_id;
      DROP INDEX IF EXISTS index_trade_shipments_on_exporter_id;
      DROP INDEX IF EXISTS index_trade_shipments_on_importer_id;
      DROP INDEX IF EXISTS index_trade_shipments_on_purpose_id;
      DROP INDEX IF EXISTS index_trade_shipments_on_quantity;
      DROP INDEX IF EXISTS index_trade_shipments_on_sandbox_id;
      DROP INDEX IF EXISTS index_trade_shipments_on_source_id;
      DROP INDEX IF EXISTS index_trade_shipments_on_taxon_concept_id;
      DROP INDEX IF EXISTS index_trade_shipments_on_reported_taxon_concept_id;
      DROP INDEX IF EXISTS index_trade_shipments_on_term_id;
      DROP INDEX IF EXISTS index_trade_shipments_on_unit_id;
      DROP INDEX IF EXISTS index_trade_shipments_on_year;
      DROP INDEX IF EXISTS index_trade_shipments_on_import_permits_ids;
      DROP INDEX IF EXISTS index_trade_shipments_on_export_permits_ids;
      DROP INDEX IF EXISTS index_trade_shipments_on_origin_permits_ids;
      DROP INDEX IF EXISTS index_trade_shipments_on_legacy_shipment_number;
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end

    def self.drop_indexes_on_trade_names
      puts "Destroy trade_names related indexes"
      sql = <<-SQL
        DROP INDEX IF EXISTS index_taxon_concepts_on_legacy_trade_code;
        DROP INDEX IF EXISTS index_trade_species_mapping_import_cites_taxon_code;
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end

    def self.create_indexes_on_trade_names
      puts "Add index for trade_names and trade_species_mapping_import"
      sql = <<-SQL
        CREATE INDEX index_taxon_concepts_on_legacy_trade_code
          ON taxon_concepts
          USING btree
          (legacy_trade_code);
        CREATE UNIQUE INDEX index_trade_species_mapping_import_cites_taxon_code
          ON trade_species_mapping_import
          USING btree
          (cites_taxon_code);
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end

    def self.create_indexes_on_shipments
      sql = <<-SQL
      CREATE INDEX index_trade_shipments_on_appendix
        ON trade_shipments
        USING btree
        (appendix COLLATE pg_catalog."default");
      CREATE INDEX index_trade_shipments_on_country_of_origin_id
        ON trade_shipments
        USING btree
        (country_of_origin_id);
      CREATE INDEX index_trade_shipments_on_exporter_id
        ON trade_shipments
        USING btree
        (exporter_id);
      CREATE INDEX index_trade_shipments_on_importer_id
        ON trade_shipments
        USING btree
        (importer_id);
      CREATE INDEX index_trade_shipments_on_purpose_id
        ON trade_shipments
        USING btree
        (purpose_id);
      CREATE INDEX index_trade_shipments_on_quantity
        ON trade_shipments
        USING btree
        (quantity);
      CREATE INDEX index_trade_shipments_on_sandbox_id
        ON trade_shipments
        USING btree
        (sandbox_id);
      CREATE INDEX index_trade_shipments_on_source_id
        ON trade_shipments
        USING btree
        (source_id);
      CREATE INDEX index_trade_shipments_on_taxon_concept_id
        ON trade_shipments
        USING btree
        (taxon_concept_id);
      CREATE INDEX index_trade_shipments_on_reported_taxon_concept_id
        ON trade_shipments
        USING btree
        (reported_taxon_concept_id);
      CREATE INDEX index_trade_shipments_on_term_id
        ON trade_shipments
        USING btree
        (term_id);
      CREATE INDEX index_trade_shipments_on_unit_id
        ON trade_shipments
        USING btree
        (unit_id);
      CREATE INDEX index_trade_shipments_on_year
        ON trade_shipments
        USING btree
        (year);
      CREATE INDEX index_trade_shipments_on_import_permits_ids
        ON trade_shipments
        USING GIN
        (import_permits_ids);
      CREATE INDEX index_trade_shipments_on_export_permits_ids
        ON trade_shipments
        USING GIN
        (export_permits_ids);
      CREATE INDEX index_trade_shipments_on_origin_permits_ids
        ON trade_shipments
        USING GIN
        (origin_permits_ids);
      CREATE INDEX index_trade_shipments_on_legacy_shipment_number
        ON trade_shipments
        USING btree
        (legacy_shipment_number);
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end

  end
end
