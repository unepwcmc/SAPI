# == Schema Information
#
# Table name: taxon_concepts
#
#  id             :integer          not null, primary key
#  parent_id      :integer
#  lft            :integer
#  rgt            :integer
#  rank_id        :integer          not null
#  designation_id :integer          not null
#  taxon_name_id  :integer          not null
#  legacy_id      :integer
#  legacy_type    :string(255)
#  data           :hstore
#  listing        :hstore
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  author_year    :string(255)
#  notes          :text
#

class TaxonConcept < ActiveRecord::Base
  attr_accessible :lft, :parent_id, :rgt, :rank_id, :parent_id,
    :designation_id, :taxon_name_id, :data, :legacy_id, :legacy_type,
    :taxon_name_attributes

  serialize :data, ActiveRecord::Coders::Hstore
  serialize :listing, ActiveRecord::Coders::Hstore

  belongs_to :rank
  belongs_to :designation
  belongs_to :taxon_name
  has_many :relationships, :class_name => 'TaxonRelationship',
    :dependent => :destroy
  has_many :related_taxon_concepts, :class_name => 'TaxonConcept',
    :through => :relationships
  has_many :taxon_concept_geo_entities
  has_many :geo_entities, :through => :taxon_concept_geo_entities
  has_many :listing_changes
  has_many :species_listings, :through => :listing_changes
  has_many :taxon_commons, :dependent => :destroy
  has_many :common_names, :through => :taxon_commons
  has_and_belongs_to_many :references, :join_table => :taxon_concept_references

  accepts_nested_attributes_for :taxon_name, :update_only => true

  validates :parent_id, :presence => true, :unless => :is_kingdom?

  before_destroy :check_destroy_allowed

  acts_as_nested_set

  scope :by_scientific_name, lambda { |scientific_name|
    where(
      <<-SQL
      data->'full_name' >= '#{TaxonName.lower_bound(scientific_name)}'
        AND data->'full_name' < '#{TaxonName.upper_bound(scientific_name)}'
      SQL
    )
  }

  scope :at_parent_ranks, lambda{ |rank|
    joins(
    <<-SQL
      INNER JOIN ranks ON ranks.id = taxon_concepts.rank_id
        AND ranks.taxonomic_position >= '#{rank.parent_rank_lower_bound}'
        AND ranks.taxonomic_position < '#{rank.taxonomic_position}'
    SQL
    )
  }

  def is_kingdom?
    rank && rank.name == Rank::KINGDOM
  end

  def full_name
    data['full_name']
  end

  def rank_name
    data['rank_name']
  end

  private

  def check_destroy_allowed
    unless can_be_deleted?
      errors.add(:base, "not allowed")
      return false
    end
  end

  def can_be_deleted?
    relationships.count == 0 &&
    children.count == 0 &&
    listing_changes.count == 0
  end

end
