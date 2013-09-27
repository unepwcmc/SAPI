module Sapi
  module StoredProcedures

    REBUILD_PROCEDURES = [
      :listing_changes_mview,
      :taxonomy,
      :cites_listing,
      :eu_listing,
      :cms_listing,
      :cites_accepted_flags,
      :taxon_concepts_mview,
      :cites_species_listing_mview,
      :eu_species_listing_mview,
      :cms_species_listing_mview
    ]

    def self.rebuild(options = {})
      Sapi::Triggers.disable_triggers
      procedures = REBUILD_PROCEDURES - (options[:except] || [])
      procedures &= options[:only] unless options[:only].nil?
      if procedures && [:taxon_concepts_mview, :listing_changes_mview]
        procedures << :touch_taxon_concepts
      end
      if procedures && [:cites_listing, :eu_listing, :cms_listing]
        procedures.unshift :listing_changes_mview
      end
      procedures.each{ |p|
        puts "Starting procedure: #{p}"
        ActiveRecord::Base.connection.execute("SELECT * FROM rebuild_#{p}()")
        puts "Ending procedure: #{p}"
      }

      changed_cnt = TaxonConcept.where('touched_at IS NOT NULL AND touched_at > updated_at').count

      if changed_cnt > 0
        # increment cache iterators if anything changed
        Species::Search.increment_cache_iterator
        Species::TaxonConceptPrefixMatcher.increment_cache_iterator
        Checklist::Checklist.increment_cache_iterator
        Checklist::TaxonConceptPrefixMatcher.increment_cache_iterator

        TaxonConcept.update_all(
          'updated_at = touched_at',
          'touched_at IS NOT NULL AND touched_at > updated_at'
        )
      end

      Sapi::Triggers.enable_triggers
    end
    
  end
end
