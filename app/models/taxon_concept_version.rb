# == Schema Information
#
# Table name: taxon_concept_versions
#
#  id               :integer          not null, primary key
#  author_year      :text
#  event            :string(255)      not null
#  full_name        :text             not null
#  item_type        :string(255)      not null
#  name_status      :text             not null
#  object           :jsonb
#  object_yml       :text
#  rank_name        :text             not null
#  taxonomy_name    :text             not null
#  whodunnit        :string(255)
#  created_at       :datetime
#  item_id          :integer          not null
#  taxon_concept_id :integer          not null
#
# Indexes
#
#  index_taxon_concept_versions_on_event                         (event)
#  index_taxon_concept_versions_on_full_name_and_created_at      (full_name,created_at)
#  index_taxon_concept_versions_on_taxonomy_name_and_created_at  (taxonomy_name,created_at)
#
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
