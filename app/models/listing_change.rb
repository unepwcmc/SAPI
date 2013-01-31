# == Schema Information
#
# Table name: listing_changes
#
#  id                         :integer          not null, primary key
#  species_listing_id         :integer
#  taxon_concept_id           :integer
#  change_type_id             :integer
#  lft                        :integer
#  rgt                        :integer
#  parent_id                  :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  effective_at               :datetime         default(2012-09-21 07:32:20 UTC), not null
#  annotation_id              :integer
#  is_current                 :boolean          default(FALSE), not null
#  inclusion_taxon_concept_id :integer
#

class ListingChange < ActiveRecord::Base

  attr_accessible :taxon_concept_id, :species_listing_id, :change_type_id,
    :effective_at, :is_current, :parent_id, :geo_entity_ids,
    :party_listing_distribution_attributes, :inclusion_scientific_name
  attr_writer :inclusion_scientific_name

  belongs_to :species_listing
  belongs_to :taxon_concept
  belongs_to :change_type
  has_many :listing_distributions, :conditions => {:is_party => false}, :dependent => :destroy
  has_one :party_listing_distribution, :class_name => 'ListingDistribution', :conditions => {:is_party => true}, :dependent => :destroy
  accepts_nested_attributes_for :party_listing_distribution, :reject_if => proc { |attributes| attributes['geo_entity_id'].blank? }
  has_many :geo_entities, :through => :listing_distributions
  has_one :party_geo_entity, :class_name => 'GeoEntity',
    :through => :party_listing_distribution, :source => :geo_entity
  belongs_to :annotation
  belongs_to :parent, :class_name => 'ListingChange'
  belongs_to :inclusion, :class_name => 'TaxonConcept'
  validates :change_type_id, :presence => true
  validates :species_listing_id, :presence => true
  validates :effective_at, :presence => true
  before_validation :check_inclusion_taxon_concept_exists

  def inclusion_scientific_name
    inclusion && includion.full_name
  end

  private
  def check_inclusion_taxon_concept_exists
    return true if inclusion_scientific_name.blank?
    tc = TaxonConcept.find_by_full_name_and_name_status(inclusion_scientific_name, 'A')
    unless tc
      errors.add(full_name_attr, "does not exist")
      return true
    end
    self.inclusion_taxon_concept_id = tc.id
    true
  end

end
