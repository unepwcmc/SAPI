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
        :valid_species_name_appendix_year_mview,
        :touch_taxon_concepts
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

  end
end
