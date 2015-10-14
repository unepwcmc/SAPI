# == Schema Information
#
# Table name: taxon_relationships
#
#  id                         :integer          not null, primary key
#  taxon_concept_id           :integer          not null
#  other_taxon_concept_id     :integer          not null
#  taxon_relationship_type_id :integer          not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  created_by_id              :integer
#  updated_by_id              :integer
#

class TaxonRelationship < ActiveRecord::Base
  track_who_does_it
  attr_accessible :taxon_concept_id, :other_taxon_concept_id, :taxon_relationship_type_id,
    :other_taxon_concept_attributes, :created_by_id, :updated_by_id
  belongs_to :taxon_relationship_type
  belongs_to :taxon_concept
  belongs_to :other_taxon_concept, :class_name => 'TaxonConcept',
    :foreign_key => :other_taxon_concept_id
  has_many :name_reassignments, :class_name => 'NomenclatureChange::NameReassignment',
    as: :reassignable, dependent: :destroy

  delegate :is_bidirectional?, :to => :taxon_relationship_type

  before_validation :check_other_taxon_concept_exists
  before_destroy :destroy_opposite, :if => Proc.new { self.is_bidirectional? && self.has_opposite? }
  after_create :create_opposite, :if => Proc.new { self.is_bidirectional? && !self.has_opposite? }
  after_save :update_higher_taxa_for_hybrid_child
  validates :taxon_concept_id, uniqueness: {
    scope: [:taxon_relationship_type_id, :other_taxon_concept_id],
    message: 'This relationship already exists, choose another taxon.'
  }
  validates :other_taxon_concept_id, presence: true
  validate :intertaxonomic_relationship_uniqueness, :if => "taxon_relationship_type.is_intertaxonomic?"

  def update_higher_taxa_for_hybrid_child
    if other_taxon_concept && taxon_relationship_type &&
      taxon_relationship_type.name == TaxonRelationshipType::HAS_HYBRID
      tcd = TaxonConceptData.new(other_taxon_concept)
      data = tcd.to_h
      other_taxon_concept.update_column(:data, ActiveRecord::Coders::Hstore.dump(data))
      other_taxon_concept.data = data
    end
  end

  def opposite
    TaxonRelationship.where(:taxon_concept_id => self.other_taxon_concept_id,
      :other_taxon_concept_id => self.taxon_concept_id,
      :taxon_relationship_type_id => self.taxon_relationship_type_id).first
  end

  def has_opposite?
    opposite.present?
  end

  private

  def check_other_taxon_concept_exists
    return true unless other_taxon_concept
    required_name_status = case taxon_relationship_type.name
      when TaxonRelationshipType::HAS_SYNONYM
        'S'
      when TaxonRelationshipType::HAS_TRADE_NAME
        'T'
      when TaxonRelationshipType::HAS_HYBRID
        'H'
      else
        'A'
    end
    existing_tc = TaxonConcept.
      where(:taxonomy_id => other_taxon_concept.taxonomy_id).
      where(:rank_id => other_taxon_concept.rank_id).
      where(:full_name => other_taxon_concept.full_name).
      where(
        if other_taxon_concept.author_year.blank?
          'SQUISH_NULL(author_year) IS NULL'
        else
          {:author_year => other_taxon_concept.author_year}
        end
      ).
      where(:name_status => required_name_status).first
    if existing_tc
      self.other_taxon_concept = existing_tc
      self.other_taxon_concept_id = existing_tc.id
    end
    true
  end

  def create_opposite
    TaxonRelationship.create(
      :taxon_concept_id => self.other_taxon_concept_id,
      :other_taxon_concept_id => self.taxon_concept_id,
      :taxon_relationship_type_id => self.taxon_relationship_type_id)
  end

  def destroy_opposite
    TaxonRelationship.where(
        :taxon_concept_id => self.other_taxon_concept_id,
        :other_taxon_concept_id => self.taxon_concept_id,
        :taxon_relationship_type_id => self.taxon_relationship_type_id).
      delete_all
  end

  #A taxon concept can only be related with another taxon concept through
  # ONE intertaxonomic Taxon Relationship. Unless the TaxonRelationships
  # share the same TaxonRelationshipType and this is bidirectional
  def intertaxonomic_relationship_uniqueness
    if TaxonRelationship.where(:taxon_concept_id => self.taxon_concept_id,
         :other_taxon_concept_id => self.other_taxon_concept_id).
         joins(:taxon_relationship_type).
         where(:taxon_relationship_types => { :is_intertaxonomic => true }).any? ||
      TaxonRelationship.where(:taxon_concept_id => self.other_taxon_concept_id,
         :other_taxon_concept_id => self.taxon_concept_id).
         joins(:taxon_relationship_type).
         where(:taxon_relationship_types => { :is_intertaxonomic => true }).where('taxon_relationship_types.id <> ?', self.taxon_relationship_type_id).any?
      errors.add(:taxon_concept_id, "these taxon are already related through another relationship.")
    end
  end
end
