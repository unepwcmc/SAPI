# == Schema Information
#
# Table name: distributions
#
#  id               :integer          not null, primary key
#  internal_notes   :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  created_by_id    :integer
#  geo_entity_id    :integer          not null
#  taxon_concept_id :integer          not null
#  updated_by_id    :integer
#
# Indexes
#
#  index_distributions_on_created_by_id     (created_by_id)
#  index_distributions_on_geo_entity_id     (geo_entity_id)
#  index_distributions_on_taxon_concept_id  (taxon_concept_id)
#  index_distributions_on_updated_by_id     (updated_by_id)
#
# Foreign Keys
#
#  distributions_created_by_id_fk                  (created_by_id => users.id)
#  distributions_updated_by_id_fk                  (updated_by_id => users.id)
#  taxon_concept_geo_entities_geo_entity_id_fk     (geo_entity_id => geo_entities.id)
#  taxon_concept_geo_entities_taxon_concept_id_fk  (taxon_concept_id => taxon_concepts.id)
#

class Distribution < ApplicationRecord
  include Changeable
  include TrackWhoDoesIt
  # Migrated to controller (Strong Parameters)
  # attr_accessible :geo_entity_id, :taxon_concept_id, :tag_list,
  #   :references_attributes, :internal_notes, :created_by_id, :updated_by_id

  acts_as_taggable

  belongs_to :geo_entity
  belongs_to :taxon_concept
  has_many :distribution_references, dependent: :destroy
  has_many :references, through: :distribution_references
  has_many :distribution_reassignments,
    class_name: 'NomenclatureChange::DistributionReassignment',
    as: :reassignable,
    dependent: :destroy
  accepts_nested_attributes_for :references, allow_destroy: true

  validates :taxon_concept_id, uniqueness: { scope: :geo_entity_id, message: 'already has this distribution' }
  before_save :normalise_blank_values

  def add_existing_references(ids)
    reference_ids = ids.split(',')

    reference_ids.each do |r|
      reference = Reference.find(r)
      unless reference.nil?
        self.distribution_references.
          create({
            distribution_id: self.id,
            reference_id: reference.id
          }
                )
      end
    end
  end

private

  def normalise_blank_values
    attributes.each do |column, value|
      self[column].present? || self[column] = nil
    end
  end
end
