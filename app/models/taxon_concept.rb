# == Schema Information
#
# Table name: taxon_concepts
#
#  id                 :integer          not null, primary key
#  parent_id          :integer
#  lft                :integer
#  rgt                :integer
#  rank_id            :integer          not null
#  designation_id     :integer          not null
#  taxon_name_id      :integer          not null
#  legacy_id          :integer
#  legacy_type        :string(255)
#  data               :hstore
#  listing            :hstore
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  author_year        :string(255)
#  notes              :text
#  taxonomic_position :string(255)      default("0"), not null
#  full_name          :string(255)
#  name_status        :string(255)      default("A"), not null
#

class TaxonConcept < ActiveRecord::Base
  attr_accessible :lft, :parent_id, :rgt, :designation_id, :rank_id,
    :parent_id, :author_year, :taxon_name_id, :taxonomic_position,
    :legacy_id, :legacy_type, :full_name, :name_status,
    :taxon_name_attributes, :common_names_attributes,
    :accepted_scientific_name,
    :parent_scientific_name
  attr_writer :parent_scientific_name, :accepted_scientific_name

  serialize :data, ActiveRecord::Coders::Hstore
  serialize :listing, ActiveRecord::Coders::Hstore

  belongs_to :rank
  belongs_to :designation
  belongs_to :taxon_name
  has_many :taxon_relationships, :dependent => :destroy
  has_many :inverse_taxon_relationships, :class_name => 'TaxonRelationship',
    :foreign_key => :other_taxon_concept_id, :dependent => :destroy
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
  accepts_nested_attributes_for :common_names, :allow_destroy => true

  validates :designation_id, :presence => true
  validates :rank_id, :presence => true
  validate :parent_in_same_designation
  validate :parent_at_immediately_higher_rank
  validates :taxon_name_id, :presence => true,
    :unless => lambda { |tc| tc.taxon_name.try(:valid?) }
  validates :taxon_name_id, :uniqueness => { :scope => [:designation_id, :parent_id] }
  validates :taxonomic_position,
    :presence => true,
    :format => { :with => /\d(\.\d*)*/, :message => "Use prefix notation, e.g. 1.2" },
    :if => :fixed_order_required?
  validates :accepted_scientific_name, :presence => true, :if => :is_synonym?

  before_validation :check_taxon_name_exists
  before_validation :check_parent_taxon_name_exists
  before_validation :check_accepted_taxon_name_exists
  before_validation :ensure_taxonomic_position
  before_destroy :check_destroy_allowed

  acts_as_nested_set

  scope :by_scientific_name, lambda { |scientific_name|
    where(
      <<-SQL
      full_name >= '#{TaxonName.lower_bound(scientific_name)}'
        AND full_name < '#{TaxonName.upper_bound(scientific_name)}'
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

  def is_synonym?
    name_status == 'S'
  end

  def rank_name
    data['rank_name']
  end

  def parent_scientific_name
    @parent_scientific_name || 
    parent && parent.full_name
  end

  def accepted_scientific_name
    @accepted_scientific_name || 
    accepted_taxon_concept && accepted_taxon_concept.full_name
  end

  def accepted_taxon_concept
    rel = inverse_taxon_relationships.joins(:taxon_relationship_type).
      where("taxon_relationship_types.name = '#{TaxonRelationshipType::HAS_SYNONYM}'").
      includes(:other_taxon_concept)
    rel.size > 0 ? rel.first.taxon_concept : nil
  end

  def synonym_taxon_concepts
    rel = taxon_relationships.joins(:taxon_relationship_type).
      where("taxon_relationship_types.name = '#{TaxonRelationshipType::HAS_SYNONYM}'").
      includes(:other_taxon_concept).map(&:other_taxon_concept)
  end

  private

  def self.normalize_full_name(some_full_name)
    #strip ranks
    if some_full_name =~ /(.+)\s*(#{Rank.dict.join('|')})\s*$/
      some_full_name = $1
    end
    #strip redundant whitespace between words
    some_full_name = some_full_name.split(/\s/).join(' ').capitalize
  end

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
      self.taxon_name_id = tn.id
    end
    true
  end

  def check_accepted_taxon_name_exists
    return true if name_status == 'A'
    return true if @accepted_scientific_name.blank?
    @accepted_scientific_name = TaxonConcept.normalize_full_name(@accepted_scientific_name)

    atc = TaxonConcept.
      where(["UPPER(full_name) = UPPER(BTRIM(?))", @accepted_scientific_name]).first
    unless atc
      errors.add(:accepted_scientific_name, "does not exist")
      return true
    end

    inverse_taxon_relationships.build(
      :taxon_concept_id => atc.id,
      :taxon_relationship_type_id => TaxonRelationshipType.find_by_name(TaxonRelationshipType::HAS_SYNONYM).id
    )
    true
  end

  def check_parent_taxon_name_exists
    return true if @parent_scientific_name.blank?
    @parent_scientific_name = TaxonConcept.normalize_full_name(@parent_scientific_name)

    p = TaxonConcept.
      where(["UPPER(full_name) = UPPER(BTRIM(?))", @parent_scientific_name]).first
    unless p
      errors.add(:parent_scientific_name, "does not exist")
      return true
    end
    self.parent_id = p.id
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
    puts taxon_commons.inspect
    taxon_relationships.count == 0 &&
    children.count == 0 &&
    listing_changes.count == 0 &&
    taxon_commons.count == 0
  end

end
