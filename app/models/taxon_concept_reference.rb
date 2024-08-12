# == Schema Information
#
# Table name: taxon_concept_references
#
#  id                          :integer          not null, primary key
#  excluded_taxon_concepts_ids :integer          is an Array
#  is_cascaded                 :boolean          default(FALSE), not null
#  is_standard                 :boolean          default(FALSE), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  created_by_id               :integer
#  reference_id                :integer          not null
#  taxon_concept_id            :integer          not null
#  updated_by_id               :integer
#
# Indexes
#
#  index_taxon_concept_references_on_tc_id_is_std_is_cascaded  (taxon_concept_id,reference_id,is_standard,is_cascaded) UNIQUE
#
# Foreign Keys
#
#  taxon_concept_references_created_by_id_fk     (created_by_id => users.id)
#  taxon_concept_references_reference_id_fk      (reference_id => references.id)
#  taxon_concept_references_taxon_concept_id_fk  (taxon_concept_id => taxon_concepts.id)
#  taxon_concept_references_updated_by_id_fk     (updated_by_id => users.id)
#

class TaxonConceptReference < ApplicationRecord
  include Changeable
  include TrackWhoDoesIt
  # Migrated to controller (Strong Parameters)
  # attr_accessible :reference_id, :taxon_concept_id, :is_standard, :is_cascaded,
  #   :excluded_taxon_concepts_ids, :reference_attributes,
  #   :created_by_id, :updated_by_id

  belongs_to :reference
  belongs_to :taxon_concept

  delegate :citation, to: :reference

  accepts_nested_attributes_for :reference

  validates :reference_id, uniqueness: { scope: [:taxon_concept_id] }

  def excluded_taxon_concepts
    ids = excluded_taxon_concepts_ids.try(:split, ',')&.flatten
    ids.flatten.present? ? TaxonConcept.where(id: ids).order(:full_name) : []
  end

  def excluded_taxon_concepts_ids
    (read_attribute(:excluded_taxon_concepts_ids) || []).compact
  end

  def excluded_taxon_concepts_ids=(ary)
    # Make sure ary won't be between double curly braces
    write_attribute(:excluded_taxon_concepts_ids, "{#{ary.delete('{}')}}")
  end

end
