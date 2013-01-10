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
  attr_accessible :lft, :parent_id, :rgt, :rank_id, :parent_id, :author_year,
    :designation_id, :taxon_name_id, :taxon_name_attributes,
    :taxonomic_position, :legacy_id, :legacy_type

  serialize :data, ActiveRecord::Coders::Hstore
  serialize :listing, ActiveRecord::Coders::Hstore

  belongs_to :rank
  belongs_to :designation
  belongs_to :taxon_name
  has_many :taxon_relationships, :dependent => :destroy
  has_many :related_taxon_concepts, :class_name => 'TaxonConcept',
    :through => :taxon_relationships
  has_many :taxon_concept_geo_entities
  has_many :geo_entities, :through => :taxon_concept_geo_entities
  has_many :listing_changes
  has_many :species_listings, :through => :listing_changes
  has_many :taxon_commons, :dependent => :destroy
  has_many :common_names, :through => :taxon_commons
  has_and_belongs_to_many :references, :join_table => :taxon_concept_references

  accepts_nested_attributes_for :taxon_name, :update_only => true

  validates :designation_id, :presence => true
  validates :rank_id, :presence => true
  validate :parent_in_same_designation
  validate :parent_at_immediately_higher_rank
  validate :taxon_name_id, :presence => true,
    :unless => lambda { |tc| tc.taxon_name.try(:valid?) }
  validates :taxonomic_position,
    :presence => true,
    :format => { :with => /\d(\.\d*)*/, :message => "Use prefix notation, e.g. 1.2" },
    :if => :fixed_order_required?

  before_validation :check_taxon_name_exists
  before_validation :ensure_taxonomic_position
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

  def fixed_order_required?
    rank && rank.fixed_order
  end

  def full_name
    data['full_name']
  end

  def rank_name
    data['rank_name']
  end

  private

  def parent_in_same_designation
    return true unless parent
    if designation_id != parent.designation_id
      errors.add(:parent_id, "must be in same designation")
      return false
    end
  end

  def parent_at_immediately_higher_rank
    return true unless parent
    unless parent.rank.taxonomic_position >= rank.parent_rank_lower_bound &&
      parent.rank.taxonomic_position < rank.taxonomic_position
      errors.add(:parent_id, "must be at immediately higher rank")
      return false
    end
  end

  def check_taxon_name_exists
    tn = taxon_name && TaxonName.where(["UPPER(scientific_name) = UPPER(?)", taxon_name.scientific_name]).first
    if tn
      self.taxon_name = tn
    end
    true
  end

  def ensure_taxonomic_position
    if new_record? && fixed_order_required? && taxonomic_position.blank?
      prev_taxonomic_position =
      if parent
        last_sibling = TaxonConcept.where(:parent_id => parent_id).maximum(:taxonomic_position)
        last_sibling || (parent.taxonomic_position + '.0')
      else
        last_root = TaxonConcept.where(:parent_id => nil).maximum(:taxonomic_position)
        last_root || '0'
      end
      prev_taxonomic_position_parts = prev_taxonomic_position.split('.')
      prev_taxonomic_position_parts << (prev_taxonomic_position_parts.pop || 0).to_i + 1
      self.taxonomic_position = prev_taxonomic_position_parts.join('.')
    end
    true
  end

  def check_destroy_allowed
    unless can_be_deleted?
      errors.add(:base, "not allowed")
      return false
    end
  end

  def can_be_deleted?
    taxon_relationships.count == 0 &&
    children.count == 0 &&
    listing_changes.count == 0
  end

end
