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
      benchmark 'SapiModule::StoredProcedures.rebuild' do
        # Each of these are done in separate transactions, so that we can
        # release locks on the taxonomy sooner.
        self.rebuild_taxonomies_and_listings
        self.rebuild_trade_plus
        self.rebuild_compliance_views
      end
    end

    def self.rebuild_taxonomies_and_listings
      benchmark 'SapiModule::StoredProcedures.rebuild_taxonomies_and_listings' do
        maintenance_transaction do |connection|
          self.get_mviews_to_lock_for_rebuild.each do |relname|
            # Lock tables in advance to prevent deadlocks forcing a rollback.
            Rails.logger.debug { "Locking table: #{relname}" }

            # We need ACCESS EXCLUSIVE because this is used by DROP TABLE, and
            # most of the rebuild_... functions are dropping and recreating the
            # so-called mviews.
            connection.execute("LOCK TABLE #{relname} IN ACCESS EXCLUSIVE MODE")
          end

          rebuild_mviews [
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
            :touch_cms_taxon_concepts
          ]

          changed_taxons = TaxonConcept.where(
            'touched_at IS NOT NULL AND touched_at > updated_at'
          )

          if changed_taxons.count > 0
            # increment cache iterators if anything changed
            Species::Search.increment_cache_iterator
            Species::TaxonConceptPrefixMatcher.increment_cache_iterator
            Checklist::Checklist.increment_cache_iterator

            changed_taxons.update_all(
              'updated_at = touched_at',
            )
          end
        end
      end
    end

    def self.rebuild_compliance_views
      benchmark 'SapiModule::StoredProcedures.rebuild_compliance_views' do
        maintenance_transaction do |connection|
          # The names of the functions beginnning 'rebuild_' to be run in sequence
          # These are actual matviews.
          rebuild_mviews [
            :trade_shipments_appendix_i_mview,
            :trade_shipments_mandatory_quotas_mview,
            :trade_shipments_cites_suspensions_mview,
            :non_compliant_shipments_view
          ]
        end
      end
    end

    def self.rebuild_trade_plus
      benchmark 'SapiModule::StoredProcedures.rebuild_trade_plus' do
        maintenance_transaction do |connection|
          # The names of the functions beginnning 'rebuild_' to be run in sequence
          # These are actual matviews.
          rebuild_mviews [
            :trade_plus_complete_mview
          ]
        end
      end
    end

    def self.get_mviews_to_lock_for_rebuild
      # Note that this seems surprising, as they're named _mview
      # when they're not actually matviews, they're tables that we're locking;
      # matviews don't respond to LOCK TABLE.
      [
        'auto_complete_taxon_concepts_mview',
        'cms_species_listing_mview',
        'eu_species_listing_mview',
        'taxon_concepts_mview',
        'valid_taxon_concept_annex_year_mview',
        'valid_taxon_concept_appendix_year_mview'
      ] + self.get_listing_changes_mviews
    end

    def self.get_listing_changes_mviews
      ActiveRecord::Base.connection.execute(
        # Note that this seems surprising, as they're named _mview
        # when they're not actually matviews, they're tables that we're locking;
        # matviews don't respond to LOCK TABLE.
        <<-SQL.squish
          SELECT relname
          FROM pg_class
          WHERE relname LIKE '%listing_changes_mview'
            AND relkind = 'r';
        SQL
      ).to_a.pluck('relname')
    end

    def self.rebuild_cms_taxonomy_and_listings
      rebuild_mviews [
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
      rebuild_mviews [
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
      rebuild_mviews [
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

    def self.rebuild_permit_numbers
      Rails.logger.debug { "Procedure: #{rebuild_permit_numbers}" }

      ApplicationRecord.connection.execute('DROP INDEX IF EXISTS index_trade_shipments_on_permits_ids')
      ApplicationRecord.connection.execute('SELECT * FROM rebuild_permit_numbers()')

      recreate_index_sql = <<-SQL.squish
        CREATE INDEX index_trade_shipments_on_permits_ids
          ON trade_shipments
          USING GIN
          (permits_ids);
      SQL

      ApplicationRecord.connection.execute(recreate_index_sql)
    end

    def self.rebuild_compliance_mviews
      rebuild_mviews [
        :trade_shipments_appendix_i_mview,
        :trade_shipments_mandatory_quotas_mview,
        :trade_shipments_cites_suspensions_mview,
        :non_compliant_shipments_view
      ]
    end

    ##
    #
    def self.benchmark(task_name)
      start_time = Time.now

      Rails.logger.debug do
        "Starting #{task_name}"
      end

      begin
        yield
      rescue StandardError => e
        end_time = Time.now
        run_time = end_time - start_time

        Rails.logger.debug do
          "Failed #{task_name} after #{run_time.truncate(2)}s"
        end

        raise e
      end

      end_time = Time.now
      run_time = end_time - start_time

      Rails.logger.debug do
        "Completed #{task_name} after #{run_time.truncate(2)}s"
      end

      run_time
    end

    ##
    # Create a transaction, within which the connection settings have increased
    # resources, per `maintenance_connection`.
    def self.maintenance_transaction
      ActiveRecord::Base.transaction do
        yield self.maintenance_connection
      end
    end

    ##
    # Within the current transaction (if any) or session (otherwise), increase
    # available resources, anticipating that we will be doing intensive
    # maintenance work.
    def self.maintenance_connection(connection = ActiveRecord::Base.connection)
      # Within the current transaction, set work_mem to a higher-than-usual
      # value, so that matviews can be built more efficiently.
      #
      # The default low value of work_mem (default 4MB) is suitable for
      # small queries with high concurrency (for instance, those performed
      # by a web server), but the restriction just hampers jobs like this.
      connection.execute("SET LOCAL work_mem TO '64MB';")

      # Within the current transaction, increase the deadlock_timeout. The
      # default low value of 1s is fine for short-running queries, but this
      # job will take much longer: we can afford to be patient to outlast
      # other queries - and we really want to avoid failing here.
      connection.execute("SET LOCAL deadlock_timeout TO '30s';")

      # Within the current transaction, increase the lock_timeout. The default
      # postgres value is 0 (infinite) but config/database.yml sets this to a
      # lower value.
      connection.execute("SET LOCAL lock_timeout TO '60s';")

      connection
    end

    def self.rebuild_trade_plus_mviews
      self.rebuild_mview 'trade_plus_complete_mview'
    end

    def self.create_trade_plus_mview_indexes
      self.execute_proc 'create_trade_plus_complete_mview_indexes'
    end

    def self.rebuild_mviews(mview_names)
      mview_names.each do |mview_name|
        rebuild_mview mview_name
      end
    end

    def self.rebuild_mview(mview_name)
      self.execute_proc "rebuild_#{mview_name}"
    end

    def self.execute_proc(proc_name)
      benchmark "#{proc_name}()" do
        ApplicationRecord.connection.execute("SELECT * FROM #{proc_name}()")
      end
    end
  end
end
