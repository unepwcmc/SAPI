# config/initializers/paper_trail.rb

PaperTrail.config.track_associations = false

# the following line is required for PaperTrail >= 4.0.0 and < 12.0.0 with Rails
PaperTrail::Rails::Engine.eager_load!

class TaxonConceptVersion < PaperTrail::Version
  # Migrated to Strong Parameters
  # attr_accessible :taxon_concept_id,
  #   :taxonomy_name,
  #   :full_name,
  #   :author_year,
  #   :name_status,
  #   :rank_name
  self.table_name = :taxon_concept_versions
  self.sequence_name = :taxon_concept_versions_id_seq
end
