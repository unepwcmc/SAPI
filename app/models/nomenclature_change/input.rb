# == Schema Information
#
# Table name: nomenclature_change_inputs
#
#  id                     :integer          not null, primary key
#  internal_note          :text             default("")
#  note_en                :text             default("")
#  note_es                :text             default("")
#  note_fr                :text             default("")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  created_by_id          :integer          not null
#  nomenclature_change_id :integer          not null
#  taxon_concept_id       :integer          not null
#  updated_by_id          :integer          not null
#
# Foreign Keys
#
#  nomenclature_change_inputs_created_by_id_fk           (created_by_id => users.id)
#  nomenclature_change_inputs_nomenclature_change_id_fk  (nomenclature_change_id => nomenclature_changes.id)
#  nomenclature_change_inputs_taxon_concept_id_fk        (taxon_concept_id => taxon_concepts.id)
#  nomenclature_change_inputs_updated_by_id_fk           (updated_by_id => users.id)
#

# Represents an input of a nomenclature change.
# Inputs are required to be existing taxon concepts.
class NomenclatureChange::Input < ApplicationRecord
  include TrackWhoDoesIt
  # Migrated to controller (Strong Parameters)
  # attr_accessible :nomenclature_change_id, :taxon_concept_id,
  #   :note_en, :note_es, :note_fr, :internal_note,
  #   :parent_reassignments_attributes,
  #   :name_reassignments_attributes,
  #   :distribution_reassignments_attributes,
  #   :legislation_reassignments_attributes

  belongs_to :nomenclature_change
  belongs_to :taxon_concept
  has_many :reassignments,
    inverse_of: :input,
    class_name: 'NomenclatureChange::Reassignment',
    foreign_key: :nomenclature_change_input_id,
    dependent: :destroy,
    autosave: true
  has_many :parent_reassignments,
    inverse_of: :input,
    class_name: 'NomenclatureChange::ParentReassignment',
    foreign_key: :nomenclature_change_input_id,
    dependent: :destroy,
    autosave: true
  has_many :name_reassignments,
    inverse_of: :input,
    class_name: 'NomenclatureChange::NameReassignment',
    foreign_key: :nomenclature_change_input_id,
    dependent: :destroy,
    autosave: true
  has_many :distribution_reassignments,
    inverse_of: :input,
    class_name: 'NomenclatureChange::DistributionReassignment',
    foreign_key: :nomenclature_change_input_id,
    dependent: :destroy,
    autosave: true
  has_many :legislation_reassignments,
    inverse_of: :input,
    class_name: 'NomenclatureChange::LegislationReassignment',
    foreign_key: :nomenclature_change_input_id,
    dependent: :destroy,
    autosave: true
  has_many :document_citation_reassignments,
    inverse_of: :input,
    class_name: 'NomenclatureChange::DocumentCitationReassignment',
    foreign_key: :nomenclature_change_input_id,
    dependent: :destroy,
    autosave: true
  accepts_nested_attributes_for :parent_reassignments, :allow_destroy => true
  accepts_nested_attributes_for :name_reassignments, :allow_destroy => true
  accepts_nested_attributes_for :distribution_reassignments, :allow_destroy => true
  accepts_nested_attributes_for :legislation_reassignments, :allow_destroy => true

  # all objects of reassignable_type that are linked to input taxon
  def reassignables_by_class(reassignable_type)
    reassignable_type.constantize.where(
      :taxon_concept_id => taxon_concept.id
    )
  end

  def listing_changes_reassignments
    legislation_reassignments.where(
      reassignable_type: 'ListingChange'
    )
  end

  def cites_suspensions_reassignments
    legislation_reassignments.where(
      reassignable_type: 'CitesSuspension'
    )
  end

  def quotas_reassignments
    legislation_reassignments.where(
      reassignable_type: 'Quota'
    )
  end

  def eu_suspensions_reassignments
    legislation_reassignments.where(
      reassignable_type: 'EuSuspension'
    )
  end

  def eu_opinions_reassignments
    legislation_reassignments.where(
      reassignable_type: 'EuOpinion'
    )
  end

  def taxon_commons_reassignments
    reassignments.where(
      reassignable_type: 'TaxonCommon'
    )
  end

  def taxon_concept_references_reassignments
    reassignments.where(
      reassignable_type: 'TaxonConceptReference'
    )
  end

  def reassignment_class
    NomenclatureChange::Reassignment
  end

  def parent_reassignment_class
    NomenclatureChange::ParentReassignment
  end

  def name_reassignment_class
    NomenclatureChange::NameReassignment
  end

  def distribution_reassignment_class
    NomenclatureChange::DistributionReassignment
  end

  def legislation_reassignment_class
    NomenclatureChange::LegislationReassignment
  end

  def document_citation_reassignment_class
    NomenclatureChange::DocumentCitationReassignment
  end
end
