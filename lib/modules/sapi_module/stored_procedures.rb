module SapiModule
  module StoredProcedures
    ##
    # This takes several hours to run:
    #
    # - The first hour is for all the views prior to trade_plus_complete view
    # - The remainder of the time is exclusively spent on trade_plus_complete_view
    #
    # Runtime grows as the database grows, and in particular the trade plus
    # dataset is growing quite a bit year on year.

    def self.rebuild
      ActiveRecord::Base.transaction do
        # The names of the functions beginnning 'rebuild_' to be run in sequence
        to_rebuild = [
          :taxonomy,
          :cites_accepted_flags,
          :listing_changes_mview,
          :cites_listing,
          :eu_listing,
          :cms_listing,
          :taxon_concepts_mview,
          :cites_species_listing_mview,
          :eu_species_listing_mview,
          :cms_species_listing_mview,
          :valid_taxon_concept_annex_year_mview,
          :valid_taxon_concept_appendix_year_mview,
          :touch_cites_taxon_concepts,
          :touch_eu_taxon_concepts,
          :touch_cms_taxon_concepts,
          :trade_shipments_appendix_i_mview,
          :trade_shipments_mandatory_quotas_mview,
          :trade_shipments_cites_suspensions_mview,
          :non_compliant_shipments_view,
          :trade_plus_complete_mview
        ]

        connection = ActiveRecord::Base.connection

        to_lock = connection.execute(
          # This is not great, because it relies on things being called mview
          # when they're not matviews, it's the tables we're locking, matviews
          # don't respond to LOCK TABLE.
          "SELECT relname FROM pg_class WHERE relname LIKE '%_mview' AND relkind = 'r';"
        ).to_a.pluck('relname')

        to_lock.each do |relname|
          # Lock tables in advance to prevent deadlocks forcing a rollback.
          Rails.logger.debug { "Locking table: #{relname}" }

          # We need ACCESS EXCLUSIVE because this is used by DROP TABLE, and
          # most of the rebuild_... functions are dropping and recreating the
          # matviews.
          connection.execute("LOCK TABLE #{relname} IN ACCESS EXCLUSIVE MODE")
        end

        to_rebuild.each do |p|
          Rails.logger.debug { "Procedure: #{p}" }

          # Within the current transaction, set work_mem to a higher-than-usual
          # value, so that matviews can be built more efficiently.
          #
          # The default low value of work_mem (default 4MB) is suitable for
          # small queries with high concurrency (for instance, those performed
          # by a web server), but the restriction just hampers jobs like this.
          connection.execute("SET work_mem TO '64MB';")

          connection.execute("SELECT * FROM rebuild_#{p}()")
        end

        changed_cnt = TaxonConcept.where('touched_at IS NOT NULL AND touched_at > updated_at').count

        if changed_cnt > 0
          # increment cache iterators if anything changed
          Species::Search.increment_cache_iterator
          Species::TaxonConceptPrefixMatcher.increment_cache_iterator
          Checklist::Checklist.increment_cache_iterator

          TaxonConcept.where(
            'touched_at IS NOT NULL AND touched_at > updated_at'
          ).update_all(
            'updated_at = touched_at',
          )
        end
      end
    end

    def self.rebuild_cms_taxonomy_and_listings
      run_procedures [
        :taxonomy,
        :cms_taxon_concepts_and_ancestors_mview,
        :cms_listing_changes_mview,
        :cms_listing,
        :taxon_concepts_mview,
        :cms_species_listing_mview,
        :touch_cms_taxon_concepts
      ]
    end

    def self.rebuild_cites_taxonomy_and_listings
      run_procedures [
        :taxonomy,
        :cites_accepted_flags,
        :cites_eu_taxon_concepts_and_ancestors_mview,
        :cites_listing_changes_mview,
        :eu_listing_changes_mview,
        :cites_listing,
        :eu_listing,
        :taxon_concepts_mview,
        :cites_species_listing_mview,
        :eu_species_listing_mview,
        # valid annex calculation must precede appendix
        :valid_taxon_concept_annex_year_mview,
        :valid_taxon_concept_appendix_year_mview,
        :touch_cites_taxon_concepts
      ]
    end

    def self.rebuild_eu_taxonomy_and_listings
      run_procedures [
        :taxonomy,
        :cites_eu_taxon_concepts_and_ancestors_mview,
        :eu_listing_changes_mview,
        :eu_listing,
        :taxon_concepts_mview,
        :eu_species_listing_mview,
        :valid_taxon_concept_annex_year_mview,
        :touch_eu_taxon_concepts
      ]
    end

    def self.run_procedures(procedures)
      procedures.each do |p|
        Rails.logger.debug { "Procedure: #{p}" }
        ApplicationRecord.connection.execute("SELECT * FROM rebuild_#{p}()")
      end
    end

    def self.rebuild_permit_numbers
      Rails.logger.debug { "Procedure: #{Rails.logger.debug}" }
      ApplicationRecord.connection.execute('DROP INDEX IF EXISTS index_trade_shipments_on_permits_ids')
      ApplicationRecord.connection.execute('SELECT * FROM rebuild_permit_numbers()')
      sql = <<-SQL.squish
      CREATE INDEX index_trade_shipments_on_permits_ids
        ON trade_shipments
        USING GIN
        (permits_ids);
      SQL
      ApplicationRecord.connection.execute(sql)
    end

    def self.rebuild_compliance_mviews
      [
        :trade_shipments_appendix_i_mview,
        :trade_shipments_mandatory_quotas_mview,
        :trade_shipments_cites_suspensions_mview,
        :non_compliant_shipments_view
      ].each do |p|
        Rails.logger.debug { "Procedure: #{p}" }
        ApplicationRecord.connection.execute("SELECT * FROM rebuild_#{p}()")
      end
    end

    def self.rebuild_trade_plus_mviews
      view = 'trade_plus_complete_mview'
      Rails.logger.debug { "Procedure: #{view}" }
      ApplicationRecord.connection.execute("SELECT * FROM rebuild_#{view}()")
    end

    def self.create_trade_plus_mview_indexes
      _function = 'create_trade_plus_complete_mview_indexes'
      Rails.logger.debug { "Procedure: #{_function}" }
      ApplicationRecord.connection.execute("SELECT * FROM #{_function}()")
    end
  end
end
