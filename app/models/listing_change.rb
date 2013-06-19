# == Schema Information
#
# Table name: listing_changes
#
#  id                         :integer          not null, primary key
#  taxon_concept_id           :integer          not null
#  species_listing_id         :integer
#  change_type_id             :integer          not null
#  effective_at               :datetime         default(2012-09-21 07:32:20 UTC), not null
#  is_current                 :boolean          default(FALSE), not null
#  annotation_id              :integer
#  parent_id                  :integer
#  inclusion_taxon_concept_id :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  hash_annotation_id         :integer
#  event_id                   :integer
#  explicit_change            :boolean          default(TRUE)
#  source_id                  :integer
#

class ListingChange < ActiveRecord::Base

  attr_accessible :taxon_concept_id, :species_listing_id, :change_type_id,
    :effective_at, :is_current, :parent_id, :scientific_name, :geo_entity_ids,
    :party_listing_distribution_attributes, :inclusion_scientific_name,
    :exclusions_attributes, :annotation_attributes, :hash_annotation_id,
    :event_id
  attr_writer :inclusion_scientific_name, :scientific_name

  belongs_to :event
  belongs_to :species_listing
  belongs_to :taxon_concept
  belongs_to :change_type
  has_many :listing_distributions, :conditions => {:is_party => false}, :dependent => :destroy
  has_one :party_listing_distribution, :class_name => 'ListingDistribution', :conditions => {:is_party => true}, :dependent => :destroy
  has_many :geo_entities, :through => :listing_distributions
  has_one :party_geo_entity, :class_name => 'GeoEntity',
    :through => :party_listing_distribution, :source => :geo_entity
  belongs_to :annotation
  belongs_to :hash_annotation, :class_name => 'Annotation'
  belongs_to :parent, :class_name => 'ListingChange'
  belongs_to :inclusion, :class_name => 'TaxonConcept', :foreign_key => 'inclusion_taxon_concept_id'
  has_many :exclusions, :class_name => 'ListingChange', :foreign_key => 'parent_id', :dependent => :destroy

  validates :change_type_id, :presence => true
  validates :effective_at, :presence => true
  validate :inclusion_at_higher_rank
  validate :species_listing_designation_mismatch
  validate :event_designation_mismatch
  validate :taxon_concept_or_geo_entities_present, :if => :is_exclusion?
  validates_associated :exclusions
  before_validation :check_inclusion_taxon_concept_exists
  before_validation :check_taxon_concept_exists

  accepts_nested_attributes_for :party_listing_distribution,
    :reject_if => proc { |attributes| attributes['geo_entity_id'].blank? }
  accepts_nested_attributes_for :exclusions,
    :reject_if => proc { |attributes|
      attributes['scientific_name'].blank? &&
      attributes['geo_entity_ids'].reject(&:blank?).empty?
    }
  accepts_nested_attributes_for :annotation,
    :reject_if => proc { |attributes|
      attributes['short_note_en'].blank?
    }

  scope :by_designation, lambda { |designation_id|
    joins(:change_type).where(:"change_types.designation_id" => designation_id)
  }

  def effective_at_formatted
    effective_at ? effective_at.strftime('%d/%m/%Y') : ''
  end

  def is_exclusion?
    change_type && change_type.name == ChangeType::EXCEPTION
  end

  def taxonomic_exclusions
    exclusions.where("taxon_concept_id != #{self.taxon_concept_id}")
  end

  def geographic_exclusions
    exclusions.where("taxon_concept_id = #{self.taxon_concept_id}")
  end

  def inclusion_scientific_name
    @inclusion_scientific_name ||
    inclusion && inclusion.full_name
  end

  def scientific_name
    @scientific_name ||
    taxon_concept && taxon_concept.full_name
  end

  private
  def check_inclusion_taxon_concept_exists
    return true if inclusion_scientific_name.blank?
    tc = TaxonConcept.find_by_full_name_and_name_status(inclusion_scientific_name, 'A')
    unless tc
      errors.add(:inclusion_scientific_name, "does not exist")
      return true
    end
    self.inclusion_taxon_concept_id = tc.id
    true
  end

  def inclusion_at_higher_rank
    return true unless inclusion
    unless inclusion.rank.taxonomic_position < taxon_concept.rank.taxonomic_position
      errors.add(:inclusion_taxon_concept_id, "must be at higher rank")
      return false
    end
  end

  def species_listing_designation_mismatch
    return true unless species_listing
    unless species_listing.designation_id == change_type.designation_id
      errors.add(:species_listing_id, "designation mismatch between change type and species listing")
      return false
    end
  end

  def event_designation_mismatch
    return true unless event
    unless event.designation_id == change_type.designation_id
      errors.add(:event_id, "designation mismatch between change type and event")
      return false
    end
  end

  def check_taxon_concept_exists
    return true if scientific_name.blank?
    tc = TaxonConcept.find_by_full_name_and_name_status(scientific_name, 'A')
    unless tc
      errors.add(:scientific_name, "does not exist")
      return true
    end
    self.taxon_concept_id = tc.id
    true
  end

  def taxon_concept_or_geo_entities_present
    unless taxon_concept || geo_entities
      errors.add(:taxon_concept, "either taxon concept or geo entities must be present")
    end
  end

end
