module Sapi
  module Triggers

    TABLES_WITH_TRIGGERS = [
      :taxon_concepts,
      :ranks,
      :taxon_names,
      :common_names,
      :taxon_commons,
      :taxon_relationships,
      :geo_entities,
      :distributions,
      :taxon_concept_references,
      :listing_changes,
      :annotations,
      :change_types,
      :species_listings,
      :listing_distributions
    ]

    def self.disable_triggers
      TABLES_WITH_TRIGGERS.each do |table|
        ActiveRecord::Base.connection.execute("ALTER TABLE #{table} DISABLE TRIGGER USER")
      end
    end

    def self.enable_triggers
      TABLES_WITH_TRIGGERS.each do |table|
        ActiveRecord::Base.connection.execute("ALTER TABLE #{table} ENABLE TRIGGER USER")
      end
    end

  end
end
