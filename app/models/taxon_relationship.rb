# == Schema Information
#
# Table name: taxon_relationships
#
#  id                         :integer          not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  created_by_id              :integer
#  other_taxon_concept_id     :integer          not null
#  taxon_concept_id           :integer          not null
#  taxon_relationship_type_id :integer          not null
#  updated_by_id              :integer
#
# Indexes
#
#  idx_on_other_taxon_concept_id_taxon_concept_id_taxo_2c9706896e  (other_taxon_concept_id,taxon_concept_id,taxon_relationship_type_id) UNIQUE
#  idx_on_taxon_concept_id_other_taxon_concept_id_taxo_71c4a75896  (taxon_concept_id,other_taxon_concept_id,taxon_relationship_type_id) UNIQUE
#  index_taxon_relationships_on_created_by_id                      (created_by_id)
#  index_taxon_relationships_on_taxon_concept_id                   (taxon_concept_id)
#  index_taxon_relationships_on_taxon_relationship_type_id         (taxon_relationship_type_id)
#  index_taxon_relationships_on_updated_by_id                      (updated_by_id)
#
# Foreign Keys
#
#  taxon_relationships_created_by_id_fk               (created_by_id => users.id)
#  taxon_relationships_taxon_concept_id_fk            (taxon_concept_id => taxon_concepts.id)
#  taxon_relationships_taxon_relationship_type_id_fk  (taxon_relationship_type_id => taxon_relationship_types.id)
#  taxon_relationships_updated_by_id_fk               (updated_by_id => users.id)
#

class TaxonRelationship < ApplicationRecord
  include Changeable
  include TrackWhoDoesIt
  # Migrated to controller (Strong Parameters)
  # attr_accessible :taxon_concept_id, :other_taxon_concept_id, :taxon_relationship_type_id,
  #   :created_by_id, :updated_by_id

  belongs_to :taxon_relationship_type
  belongs_to :taxon_concept
  belongs_to :other_taxon_concept, class_name: 'TaxonConcept'
  has_many :name_reassignments,
    class_name: 'NomenclatureChange::NameReassignment',
    as: :reassignable,
    dependent: :destroy

  delegate :is_bidirectional?, to: :taxon_relationship_type

  after_create :create_opposite, if: Proc.new { self.is_bidirectional? && !self.has_opposite? }
  before_destroy :destroy_opposite, if: Proc.new { self.is_bidirectional? && self.has_opposite? }
  after_save :update_higher_taxa_for_hybrid_child
  validates :taxon_concept_id, uniqueness: {
    scope: [ :taxon_relationship_type_id, :other_taxon_concept_id ],
    message: 'This relationship already exists, choose another taxon.'
  }
  validate :intertaxonomic_relationship_uniqueness, if: -> { taxon_relationship_type.is_intertaxonomic? }

  scope :hybrids, -> {
    where(
      "taxon_relationship_type_id IN
      (SELECT id FROM taxon_relationship_types
        WHERE name = '#{TaxonRelationshipType::HAS_HYBRID}'
      )"
    )
  }

  scope :trades, -> {
    where(
      "taxon_relationship_type_id IN
      (SELECT id FROM taxon_relationship_types
        WHERE name = '#{TaxonRelationshipType::HAS_TRADE_NAME}'
      )"
    )
  }

  scope :synonyms, -> {
    where(
      "taxon_relationship_type_id IN
      (SELECT id FROM taxon_relationship_types
        WHERE name = '#{TaxonRelationshipType::HAS_SYNONYM}'
      )"
    )
  }


  def update_higher_taxa_for_hybrid_child
    if other_taxon_concept && taxon_relationship_type &&
      taxon_relationship_type.name == TaxonRelationshipType::HAS_HYBRID
      tcd = TaxonConceptData.new(other_taxon_concept)
      data = tcd.to_h
      other_taxon_concept.update_column(:data, data)
      other_taxon_concept.data = data
    end
  end

  def opposite
    TaxonRelationship.where(
      taxon_concept_id: self.other_taxon_concept_id,
      other_taxon_concept_id: self.taxon_concept_id,
      taxon_relationship_type_id: self.taxon_relationship_type_id
    ).first
  end

  def has_opposite?
    opposite.present?
  end

private

  def create_opposite
    TaxonRelationship.create(
      taxon_concept_id: self.other_taxon_concept_id,
      other_taxon_concept_id: self.taxon_concept_id,
      taxon_relationship_type_id: self.taxon_relationship_type_id
    )
  end

  def destroy_opposite
    TaxonRelationship.where(
      taxon_concept_id: self.other_taxon_concept_id,
      other_taxon_concept_id: self.taxon_concept_id,
      taxon_relationship_type_id: self.taxon_relationship_type_id
    ).
      delete_all
  end

  # A taxon concept can only be related with another taxon concept through
  # ONE intertaxonomic Taxon Relationship. Unless the TaxonRelationships
  # share the same TaxonRelationshipType and this is bidirectional
  def intertaxonomic_relationship_uniqueness
    if TaxonRelationship.where(
      taxon_concept_id: self.taxon_concept_id,
      other_taxon_concept_id: self.other_taxon_concept_id
    ).
        joins(:taxon_relationship_type).
        where(taxon_relationship_types: { is_intertaxonomic: true }).any? ||
      TaxonRelationship.where(
        taxon_concept_id: self.other_taxon_concept_id,
        other_taxon_concept_id: self.taxon_concept_id
      ).
          joins(:taxon_relationship_type).
          where(taxon_relationship_types: { is_intertaxonomic: true }).where.not(taxon_relationship_types: { id: self.taxon_relationship_type_id }).any?
      errors.add(:taxon_concept_id, 'these taxon are already related through another relationship.')
    end
  end
end
