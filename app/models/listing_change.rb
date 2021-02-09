# == Schema Information
#
# Table name: listing_changes
#
#  id                         :integer          not null, primary key
#  taxon_concept_id           :integer          not null
#  species_listing_id         :integer
#  change_type_id             :integer          not null
#  annotation_id              :integer
#  hash_annotation_id         :integer
#  effective_at               :datetime         default(2012-09-21 07:32:20 UTC), not null
#  is_current                 :boolean          default(FALSE), not null
#  parent_id                  :integer
#  inclusion_taxon_concept_id :integer
#  event_id                   :integer
#  original_id                :integer
#  explicit_change            :boolean          default(TRUE)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  import_row_id              :integer
#  created_by_id              :integer
#  updated_by_id              :integer
#  nomenclature_note_en       :text
#  nomenclature_note_es       :text
#  nomenclature_note_fr       :text
#  internal_notes             :text
#

class ListingChange < ActiveRecord::Base
  track_who_does_it
  attr_accessible :taxon_concept_id, :species_listing_id, :change_type_id,
    :effective_at, :is_current, :parent_id, :geo_entity_ids,
    :party_listing_distribution_attributes, :inclusion_taxon_concept_id,
    :annotation_attributes, :hash_annotation_id, :event_id,
    :excluded_geo_entities_ids, :excluded_taxon_concepts_ids, :internal_notes,
    :nomenclature_note_en, :nomenclature_note_es, :nomenclature_note_fr,
    :created_by_id, :updated_by_id

  attr_accessor :excluded_geo_entities_ids, :excluded_taxon_concepts_ids

  belongs_to :event
  has_many :listing_change_copies, :foreign_key => :original_id,
    :class_name => "ListingChange", :dependent => :nullify
  belongs_to :species_listing
  belongs_to :taxon_concept
  belongs_to :change_type
  has_many :listing_distributions, -> { where is_party: false }, :dependent => :destroy
  has_one :party_listing_distribution, -> { where is_party: true }, :class_name => 'ListingDistribution',
     :dependent => :destroy
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

  accepts_nested_attributes_for :party_listing_distribution,
    :reject_if => proc { |attributes| attributes['geo_entity_id'].blank? }

  accepts_nested_attributes_for :annotation

  translates :nomenclature_note

  scope :by_designation, lambda { |designation_id|
    joins(:change_type).where(:"change_types.designation_id" => designation_id)
  }

  scope :none, -> { where("1 = 0") }

  def effective_at_formatted
    effective_at ? effective_at.strftime('%d/%m/%Y') : ''
  end

  def is_exclusion?
    change_type && change_type.name == ChangeType::EXCEPTION
  end

  def taxonomic_exclusions
    return ListingChange.none if new_record?
    exclusions.where("taxon_concept_id != #{self.taxon_concept_id}")
  end

  def excluded_taxon_concepts
    taxonomic_exclusions.includes(:taxon_concept).map(&:taxon_concept).flatten
  end

  def geographic_exclusions
    return ListingChange.none if new_record?
    exclusions.where("taxon_concept_id = #{self.taxon_concept_id}")
  end

  def excluded_geo_entities
    geographic_exclusions.includes(:listing_distributions => :geo_entity).map do |e|
      e.listing_distributions.map(&:geo_entity)
    end.flatten
  end

  def inclusion_scientific_name
    @inclusion_scientific_name ||
    inclusion && inclusion.full_name
  end

  def scientific_name
    @scientific_name ||
    taxon_concept && taxon_concept.full_name
  end

  def self.search(query)
    if query.present?
      where("UPPER(taxon_concepts.full_name) LIKE UPPER(:query)
             OR UPPER(change_types.name) LIKE UPPER(:query)
            ", :query => "%#{query}%")
    else
      all
    end
  end

  def self.ignored_attributes
    super() + [:source_id, :annotation_id, :import_row_id]
  end

  def self.text_attributes
    [:internal_notes, :nomenclature_note_en, :nomenclature_note_es, :nomenclature_note_fr]
  end

  def duplicates(comparison_attributes_override = {})
    relation = ListingChange.where(
      comparison_conditions(
        comparison_attributes.merge(comparison_attributes_override.symbolize_keys)
      )
    )
    if party_listing_distribution
      relation = relation.includes(:party_listing_distribution).where(
        party_listing_distribution.comparison_conditions(
          party_listing_distribution.comparison_attributes.except(:listing_change_id)
        )
      )
    end
    if annotation
      relation = relation.includes(:annotation).where(
        annotation.comparison_conditions
      )
    end
    relation
  end

  def is_cites?
    change_type.try(:designation).try(:is_cites?)
  end

  def is_eu?
    change_type.try(:designation).try(:is_eu?)
  end

  private

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
end
