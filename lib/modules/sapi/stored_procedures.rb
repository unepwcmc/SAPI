module Sapi
  module StoredProcedures

    REBUILD_PROCEDURES = [
      :taxonomy,
      :cites_listing,
      :eu_listing,
      :cms_listing,
      :cites_accepted_flags,
      :taxon_concepts_mview,
      :listing_changes_mview
    ]

    def self.rebuild(options = {})
      Sapi::Triggers.disable_triggers if options[:disable_triggers]
      procedures = REBUILD_PROCEDURES - (options[:except] || [])
      procedures &= options[:only] unless options[:only].nil?
      procedures.each{ |p|
        puts "Starting procedure: #{p}"
        ActiveRecord::Base.connection.execute("SELECT * FROM rebuild_#{p}()")
        puts "Ending procedure: #{p}"
      }
      Sapi::Triggers.enable_triggers if options[:disable_triggers]
    end
    
  end
end
