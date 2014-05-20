module Sapi
  module StoredProcedures

    def self.rebuild
      [
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
      ].each{ |p|
        puts "Procedure: #{p}"
        ActiveRecord::Base.connection.execute("SELECT * FROM rebuild_#{p}()")
      }

      changed_cnt = TaxonConcept.where('touched_at IS NOT NULL AND touched_at > updated_at').count

      if changed_cnt > 0
        # increment cache iterators if anything changed
        Species::Search.increment_cache_iterator
        Species::TaxonConceptPrefixMatcher.increment_cache_iterator
        Checklist::Checklist.increment_cache_iterator

        TaxonConcept.update_all(
          'updated_at = touched_at',
          'touched_at IS NOT NULL AND touched_at > updated_at'
        )
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
      procedures.each{ |p|
        puts "Procedure: #{p}"
        ActiveRecord::Base.connection.execute("SELECT * FROM rebuild_#{p}()")
      }
    end

    def self.rebuild_permit_numbers
      puts "Procedure: #{p}"
      ActiveRecord::Base.connection.execute("DROP INDEX IF EXISTS index_trade_shipments_on_permits_ids")
      ActiveRecord::Base.connection.execute("SELECT * FROM rebuild_permit_numbers()")
      sql = <<-SQL
      CREATE INDEX index_trade_shipments_on_permits_ids
        ON trade_shipments
        USING GIN
        (permits_ids);
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end
  end
end
