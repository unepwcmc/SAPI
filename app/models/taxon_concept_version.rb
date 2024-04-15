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
