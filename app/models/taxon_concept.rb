# == Schema Information
#
# Table name: taxon_concepts
#
#  id                         :integer          not null, primary key
#  taxonomy_id                :integer          default(1), not null
#  parent_id                  :integer
#  rank_id                    :integer          not null
#  taxon_name_id              :integer          not null
#  author_year                :string(255)
#  legacy_id                  :integer
#  legacy_type                :string(255)
#  data                       :hstore
#  listing                    :hstore
#  notes                      :text
#  taxonomic_position         :string(255)      default("0"), not null
#  full_name                  :string(255)
#  name_status                :string(255)      default("A"), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  touched_at                 :datetime
#  legacy_trade_code          :string(255)
#  updated_by_id              :integer
#  created_by_id              :integer
#  dependents_updated_at      :datetime
#  nomenclature_note_en       :text
#  nomenclature_note_es       :text
#  nomenclature_note_fr       :text
#  internal_nomenclature_note :text
#  dependents_updated_by_id   :integer
#

class TaxonConcept < ActiveRecord::Base
  track_who_does_it
  has_paper_trail class_name: 'TaxonConceptVersion', on: :destroy,
    meta: {
      taxon_concept_id: :id,
      taxonomy_name: :taxonomy_name,
      full_name: :full_name,
      author_year: :author_year,
      name_status: :name_status,
      rank_name: :rank_name
    }

  attr_accessible :parent_id, :taxonomy_id, :rank_id,
    :parent_id, :author_year, :taxon_name_id, :taxonomic_position,
    :legacy_id, :legacy_type, :scientific_name, :name_status,
    :tag_list, :legacy_trade_code, :hybrid_parents_ids,
    :accepted_names_ids, :accepted_names_for_trade_name_ids,
    :nomenclature_note_en, :nomenclature_note_es, :nomenclature_note_fr,
    :created_by_id, :updated_by_id, :dependents_updated_at, :kew_id

  attr_writer :accepted_names_ids,
    :accepted_names_for_trade_name_ids,
    :hybrid_parents_ids

  acts_as_taggable

  # serialize :data, ActiveRecord::Coders::Hstore
  # serialize :listing, ActiveRecord::Coders::Hstore

  has_one :m_taxon_concept, :foreign_key => :id

  belongs_to :dependents_updater, foreign_key: :dependents_updated_by_id, class_name: User
  belongs_to :parent, :class_name => 'TaxonConcept'
  has_many :children, -> { where(name_status: ['A', 'N']) }, class_name: 'TaxonConcept', foreign_key: :parent_id # conditions: { name_status: ['A', 'N'] }
  belongs_to :rank
  belongs_to :taxonomy
  has_many :designations, :through => :taxonomy
  belongs_to :taxon_name
  has_many :taxon_relationships, :dependent => :destroy
  has_many :inverse_taxon_relationships, :class_name => 'TaxonRelationship',
    :foreign_key => :other_taxon_concept_id, :dependent => :destroy
  has_many :related_taxon_concepts, :class_name => 'TaxonConcept',
    :through => :taxon_relationships
  has_many :synonym_relationships, -> { TaxonRelationship.synonyms },
    :class_name => 'TaxonRelationship', :dependent => :destroy

  has_many :inverse_synonym_relationships, -> { TaxonRelationship.synonyms },
    :class_name => 'TaxonRelationship',
    :foreign_key => :other_taxon_concept_id, :dependent => :destroy

  has_many :synonyms, :class_name => 'TaxonConcept',
    :through => :synonym_relationships, :source => :other_taxon_concept
  has_many :accepted_names, :class_name => 'TaxonConcept',
    :through => :inverse_synonym_relationships, :source => :taxon_concept
  has_many :hybrid_relationships, -> { TaxonRelationship.hybrids },
    :class_name => 'TaxonRelationship', :dependent => :destroy

  has_many :inverse_hybrid_relationships, -> { TaxonRelationship.hybrids },
    :class_name => 'TaxonRelationship',
    :foreign_key => :other_taxon_concept_id, :dependent => :destroy

  has_many :hybrids, :class_name => 'TaxonConcept',
    :through => :hybrid_relationships, :source => :other_taxon_concept
  has_many :hybrid_parents, :class_name => 'TaxonConcept',
    :through => :inverse_hybrid_relationships, :source => :taxon_concept
  has_many :trade_name_relationships, -> { TaxonRelationship.trades },
    :class_name => 'TaxonRelationship', :dependent => :destroy

  has_many :inverse_trade_name_relationships, -> { TaxonRelationship.trades },
    :class_name => 'TaxonRelationship',
    :foreign_key => :other_taxon_concept_id, :dependent => :destroy

  has_many :trade_names, :class_name => 'TaxonConcept',
    :through => :trade_name_relationships, :source => :other_taxon_concept
  has_many :accepted_names_for_trade_name, :class_name => 'TaxonConcept',
    :through => :inverse_trade_name_relationships, :source => :taxon_concept
  has_many :distributions, :dependent => :destroy
  has_many :geo_entities, :through => :distributions
  has_many :listing_changes
  has_many :current_listing_changes,  -> { where 'is_current = true' }, :class_name => 'ListingChange'
  has_many :species_listings, :through => :listing_changes
  has_many :taxon_commons, -> { includes :common_name }, :dependent => :destroy
  has_many :common_names, :through => :taxon_commons

  has_many :taxon_concept_references, -> { includes :reference }, :dependent => :destroy
  has_many :references, :through => :taxon_concept_references

  has_many :quotas, -> { order 'start_date DESC' }
  has_many :current_quotas, -> { where "is_current = true" }, :class_name => 'Quota'

  has_many :cites_suspensions
  has_many :current_cites_suspensions, -> { where "is_current = true" }, :class_name => 'CitesSuspension'

  has_many :eu_opinions
  has_many :current_eu_opinions, -> { where "is_current = true" }, :class_name => 'EuOpinion'
  has_many :eu_suspensions
  has_many :current_eu_suspensions, -> { where "is_current = true" }, :class_name => 'EuSuspension'

  has_many :taxon_instruments
  has_many :instruments, :through => :taxon_instruments
  has_many :shipments, :class_name => 'Trade::Shipment'
  has_many :reported_shipments, :class_name => 'Trade::Shipment',
    :foreign_key => :reported_taxon_concept_id
  has_many :comments, as: 'commentable'
  has_one :general_comment, -> { where comment_type: 'General' }, class_name: 'Comment', as: 'commentable'
  has_one :nomenclature_comment, -> { where comment_type: 'Nomenclature' }, class_name: 'Comment', as: 'commentable'
  has_one :distribution_comment, -> { where comment_type: 'Distribution' }, class_name: 'Comment', as: 'commentable'
  has_many :parent_reassignments,
    class_name: 'NomenclatureChange::ParentReassignment',
    as: :reassignable,
    dependent: :destroy
  has_many :nomenclature_change_inputs, class_name: 'NomenclatureChange::Input'
  has_many :nomenclature_change_outputs, class_name: 'NomenclatureChange::Output'
  has_many :nomenclature_change_outputs_as_new, class_name: 'NomenclatureChange::Output',
    foreign_key: :new_taxon_concept_id
  has_many :document_citation_taxon_concepts

  validates :taxonomy_id, :presence => true
  validates :rank_id, :presence => true
  validates :name_status, :presence => true
  validates :parent_id, presence: true,
    if: lambda { |tc| ['A', 'N'].include?(tc.name_status) && tc.rank.try(:name) != 'KINGDOM' }
  validate :parent_in_same_taxonomy, :if => lambda { |tc| tc.parent }
  validate :parent_at_immediately_higher_rank,
    :if => lambda { |tc| tc.parent && tc.name_status == 'A' }
  validate :parent_is_an_accepted_name, :if => lambda { |tc| tc.parent && tc.name_status == 'A' }
  validate :maximum_2_hybrid_parents,
    :if => lambda { |tc| tc.name_status == 'H' }
  validates :taxon_name_id, :presence => true,
    :unless => lambda { |tc| tc.taxon_name.try(:valid?) }
  validates :full_name, :uniqueness => { :scope => [:taxonomy_id, :author_year] }
  validate :full_name_cannot_be_changed, on: :update
  validates :taxonomic_position,
    :presence => true,
    :format => { :with => /\A\d(\.\d*)*\z/, :message => "Use prefix notation, e.g. 1.2" },
    :if => :fixed_order_required?
  validate :taxonomy_can_be_changed, :on => :update, :if => lambda { |tc|
    tc.taxonomy && tc.taxonomy_id_changed?
  }

  before_validation :ensure_taxonomic_position

  translates :nomenclature_note

  scope :at_parent_ranks, lambda { |rank|
    joins_sql = <<-SQL
      INNER JOIN ranks ON ranks.id = taxon_concepts.rank_id
        AND ranks.taxonomic_position >= ?
        AND ranks.taxonomic_position < ?
    SQL
    joins(
      sanitize_sql_array([
        joins_sql, rank.parent_rank_lower_bound, rank.taxonomic_position
      ])
    )
  }

  scope :at_ancestor_ranks, lambda { |rank|
    joins_sql = <<-SQL
      INNER JOIN ranks ON ranks.id = taxon_concepts.rank_id
        AND ranks.taxonomic_position < ?
    SQL
    joins(
      sanitize_sql_array([joins_sql, rank.taxonomic_position])
    )
  }

  scope :at_self_and_ancestor_ranks, lambda { |rank|
    joins_sql = <<-SQL
      INNER JOIN ranks ON ranks.id = taxon_concepts.rank_id
        AND ranks.taxonomic_position <= ?
    SQL
    joins(
      sanitize_sql_array([joins_sql, rank.taxonomic_position])
    )
  }

  def self.fetch_taxons_full_name(taxon_ids)
    if taxon_ids.present?
      ActiveRecord::Base.connection.execute(
        <<-SQL
          SELECT tc.full_name
          FROM taxon_concepts tc
          WHERE tc.id = ANY (ARRAY#{taxon_ids.map(&:to_i)})
          ORDER BY tc.id
        SQL
      ).map { |row| row['full_name'] }
    end
  end

  def scientific_name=(str)
    scientific_name =
      if ['A', 'N'].include?(name_status)
        TaxonName.sanitize_scientific_name(str)
      else
        str
      end
    tn = TaxonName.where(["UPPER(scientific_name) = UPPER(?)", scientific_name]).first
    if tn
      self.taxon_name = tn
      self.taxon_name_id = tn.id
    else
      self.build_taxon_name(scientific_name: scientific_name)
    end
  end

  def scientific_name
    taxon_name.try(:scientific_name)
  end

  def has_comments?
    general_comment.try(:note).try(:present?) ||
      nomenclature_comment.try(:note).try(:present?) ||
      distribution_comment.try(:note).try(:present?)
  end

  def taxonomy_name
    taxonomy.try(:name)
  end

  def under_cites_eu?
    taxonomy_name == Taxonomy::CITES_EU
  end

  def fixed_order_required?
    rank && rank.fixed_order
  end

  def has_synonyms?
    synonyms.count > 0
  end

  def has_accepted_names?
    inverse_synonym_relationships.limit(1).count > 0
  end

  def is_accepted_name?
    name_status == 'A'
  end

  def is_synonym?
    name_status == 'S'
  end

  def has_hybrids?
    hybrids.count > 0
  end

  def has_hybrid_parents?
    inverse_hybrid_relationships.limit(1).count > 0
  end

  def is_hybrid?
    name_status == 'H'
  end

  def has_trade_names?
    trade_names.count > 0
  end

  def has_accepted_names_for_trade_name?
    inverse_trade_name_relationships.limit(1).count > 0
  end

  def is_trade_name?
    name_status == 'T'
  end

  def has_distribution?
    distributions.count > 0
  end

  def rank_name
    data['rank_name'] || self.rank.try(:name)
  end

  def cites_accepted
    data['cites_accepted']
  end

  def cites_listed
    listing['cites_status'] == 'LISTED' && listing['cites_level_of_listing']
  end

  def eu_listed
    listing['eu_status'] == 'LISTED' && listing['eu_level_of_listing']
  end

  def standard_taxon_concept_references
    TaxonConceptReference.from('api_taxon_references_view taxon_concept_references').
      where(taxon_concept_id: self.id, is_standard: true)
  end

  def inherited_standard_taxon_concept_references
    ref_ids = taxon_concept_references.map(&:reference_id)
    standard_taxon_concept_references.keep_if { |ref| !ref_ids.include? ref.id }
  end

  def expected_full_name(parent)
    if self.rank &&
      Rank.in_range(Rank::VARIETY, Rank::SPECIES).include?(self.rank.name)
      parent.full_name +
        if self.rank.name == Rank::VARIETY
          ' var. '
        else
          ' '
        end + (self.taxon_name.try(:scientific_name).try(:downcase) || '')
    else
      self.full_name
    end
  end

  def rebuild_taxonomy?(params)
    new_full_name = params[:taxon_concept] ? params[:taxon_concept][:full_name] : ''
    new_full_name && new_full_name != full_name &&
      Rank.in_range(Rank::VARIETY, Rank::GENUS).include?(rank.name)
  end

  def accepted_names_ids
    @accepted_names_ids || accepted_names.pluck(:id)
  end

  def accepted_names_for_trade_name_ids
    @accepted_names_for_trade_name_ids ||
    accepted_names_for_trade_name.pluck(:id)
  end

  def hybrid_parents_ids
    @hybrid_parents_ids || hybrid_parents.pluck(:id)
  end

  def rebuild_relationships(taxa_ids)
    if ['S', 'T', 'H'].include? name_status
      new_taxa, removed_taxa = init_accepted_taxa(taxa_ids)
      rel_type =
        case name_status
        when 'S'
          TaxonRelationshipType.find_by_name(TaxonRelationshipType::HAS_SYNONYM)
        when 'T'
          TaxonRelationshipType.find_by_name(TaxonRelationshipType::HAS_TRADE_NAME)
        when 'H'
          TaxonRelationshipType.find_by_name(TaxonRelationshipType::HAS_HYBRID)
        end
      add_remove_relationships(new_taxa, removed_taxa, rel_type)
    end
  end

  private

  def add_remove_relationships(new_taxa, removed_taxa, rel_type)
    removed_taxa.each do |taxon_concept|
      taxon_concept.taxon_relationships.
        where('other_taxon_concept_id = ? AND
              taxon_relationship_type_id = ?', id, rel_type.id).
        destroy_all
    end

    new_taxa.each do |taxon_concept|
      taxon_concept.taxon_relationships << TaxonRelationship.new(
        :taxon_relationship_type_id => rel_type.id,
        :other_taxon_concept_id => id
      )
    end
  end

  def init_accepted_taxa(new_ids)
    return [[], []] unless ['S', 'T', 'H'].include?(name_status)
    current_ids =
      case name_status
      when 'S' then accepted_names.pluck(:id)
      when 'T' then accepted_names_for_trade_name.pluck(:id)
      when 'H' then hybrid_parents.pluck(:id)
      end
    ids_to_add = new_ids - current_ids
    ids_to_remove = current_ids - new_ids

    [
      TaxonConcept.where(id: ids_to_add),
      TaxonConcept.where(id: ids_to_remove)
    ]
  end

  def dependent_objects_map
    {
      'children' => children,
      'listing changes' => listing_changes,
      'CITES suspensions' => cites_suspensions,
      'quotas' => quotas,
      'EU suspensions' => eu_suspensions,
      'EU opinions' => eu_opinions,
      'instruments' => taxon_instruments,
      'shipments' => shipments,
      'shipments (reported as)' => reported_shipments,
      'nomenclature changes (as input)' => nomenclature_change_inputs,
      'nomenclature changes (as output)' => nomenclature_change_outputs,
      'nomenclature changes (as new output)' => nomenclature_change_outputs_as_new,
      'document citations' => document_citation_taxon_concepts
    }
  end

  def self.sanitize_full_name(some_full_name)
    # strip ranks
    if some_full_name =~ /\A(.+)\s+(#{Rank.dict.join('|')})\s*\Z/
      some_full_name = $1
    end
    # strip redundant whitespace between words
    some_full_name = some_full_name.split(/\s/).join(' ').capitalize
  end

  def taxonomy_can_be_changed
    if !can_be_deleted?
      errors.add(:taxonomy_id, "dependent objects present, unable to change taxonomy")
      return false
    end
  end

  def parent_is_an_accepted_name
    unless ['A', 'N'].include?(parent.name_status)
      errors.add(:parent_id, "must be an accepted name")
      return false
    end
  end

  def parent_in_same_taxonomy
    if taxonomy_id != parent.taxonomy_id
      errors.add(:parent_id, "must be in same taxonomy")
      return false
    end
  end

  def parent_at_immediately_higher_rank
    return true if (parent.rank.name == 'KINGDOM' && parent.full_name == 'Plantae' && rank.name == 'ORDER')
    unless parent.rank.taxonomic_position >= rank.parent_rank_lower_bound &&
      parent.rank.taxonomic_position < rank.taxonomic_position
      errors.add(:parent_id, "must be at immediately higher rank")
      return false
    end
  end

  def maximum_2_hybrid_parents
    if hybrid_parents_ids.size > 2
      errors.add(:hybrid_parents_ids, "maximum 2 hybrid parents")
      return false
    end
    true
  end

  def ensure_taxonomic_position
    if new_record? && fixed_order_required? && taxonomic_position.blank?
      prev_taxonomic_position =
        if parent
          last_sibling = TaxonConcept.where(:parent_id => parent_id).
            maximum(:taxonomic_position)
          last_sibling || (parent.taxonomic_position + '.0')
        else
          last_root = TaxonConcept.where(:parent_id => nil).
            maximum(:taxonomic_position)
          last_root || '0'
        end
      prev_taxonomic_position_parts = prev_taxonomic_position.split('.')
      prev_taxonomic_position_parts << (prev_taxonomic_position_parts.pop || 0).to_i + 1
      self.taxonomic_position = prev_taxonomic_position_parts.join('.')
    end
    true
  end

  def full_name_cannot_be_changed
    if full_name != full_name_was
      errors.add(:full_name, "cannot be changed")
      return false
    end
    true
  end

end
