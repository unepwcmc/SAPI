# == Schema Information
#
# Table name: nomenclature_change_outputs
#
#  id                     :integer          not null, primary key
#  nomenclature_change_id :integer          not null
#  taxon_concept_id       :integer
#  new_taxon_concept_id   :integer
#  new_parent_id          :integer
#  new_rank_id            :integer
#  new_scientific_name    :string(255)
#  new_author_year        :string(255)
#  new_name_status        :string(255)
#  note_en                :text
#  note_es                :text
#  note_fr                :text
#  created_by_id          :integer          not null
#  updated_by_id          :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  internal_note          :text
#  is_primary_output      :boolean          default(TRUE)
#  parent_id              :integer
#  rank_id                :integer
#  scientific_name        :string(255)
#  author_year            :string(255)
#  name_status            :string(255)
#

# Represents an output of a nomenclature change.
# Outputs may be new taxon concepts, created as a result of the nomenclature
# change.
class NomenclatureChange::Output < ActiveRecord::Base
  include PgArrayParser
  track_who_does_it
  attr_accessible :nomenclature_change_id, :taxon_concept_id,
    :new_taxon_concept_id, :rank_id, :new_scientific_name, :new_author_year,
    :new_name_status, :new_parent_id, :new_rank_id, :taxonomy_id, :accepted_taxon_ids,
    :note_en, :note_es, :note_fr, :internal_note, :is_primary_output,
    :parent_reassignments_attributes, :name_reassignments_attributes,
    :distribution_reassignments_attributes, :legislation_reassignments_attributes, :hybrid_parent_id, :other_hybrid_parent_id
  belongs_to :nomenclature_change
  belongs_to :taxon_concept
  belongs_to :parent, :class_name => TaxonConcept, :foreign_key => :parent_id
  belongs_to :rank
  belongs_to :new_taxon_concept, :class_name => TaxonConcept, :foreign_key => :new_taxon_concept_id
  has_many :reassignments, :inverse_of => :output,
    :class_name => NomenclatureChange::OutputReassignment,
    :foreign_key => :nomenclature_change_output_id, :dependent => :destroy,
    :autosave => true
  has_many :parent_reassignments, :inverse_of => :output,
    :class_name => NomenclatureChange::OutputParentReassignment,
    :foreign_key => :nomenclature_change_output_id, :dependent => :destroy,
    :autosave => true
  has_many :name_reassignments, :inverse_of => :output,
    :class_name => NomenclatureChange::OutputNameReassignment,
    :foreign_key => :nomenclature_change_output_id, :dependent => :destroy,
    :autosave => true
  has_many :distribution_reassignments, :inverse_of => :output,
    :class_name => NomenclatureChange::OutputDistributionReassignment,
    :foreign_key => :nomenclature_change_output_id, :dependent => :destroy,
    :autosave => true
  has_many :legislation_reassignments, :inverse_of => :output,
    :class_name => NomenclatureChange::OutputLegislationReassignment,
    :foreign_key => :nomenclature_change_output_id, :dependent => :destroy,
    :autosave => true
  has_many :reassignment_targets, :inverse_of => :output,
    :class_name => NomenclatureChange::ReassignmentTarget,
    :foreign_key => :nomenclature_change_output_id, :dependent => :destroy
  belongs_to :new_parent, :class_name => TaxonConcept, :foreign_key => :new_parent_id
  belongs_to :new_rank, :class_name => Rank, :foreign_key => :new_rank_id
  belongs_to :hybrid_parent, :class_name => TaxonConcept, :foreign_key => :hybrid_parent_id
  belongs_to :other_hybrid_parent, :class_name => TaxonConcept, :foreign_key => :other_hybrid_parent_id
  validates :nomenclature_change, :presence => true
  validates :new_scientific_name, :presence => true,
    :if => Proc.new { |c| c.taxon_concept_id.blank? && !c.nomenclature_change.is_a?(NomenclatureChange::NewName) }
  validates :new_parent_id, :presence => true,
    :if => Proc.new { |c| c.taxon_concept_id.blank? && !c.nomenclature_change.is_a?(NomenclatureChange::NewName) }
  validate :validate_tmp_taxon_concept,
    :if => Proc.new { |c| (c.will_create_taxon? || c.will_update_taxon?) && !c.nomenclature_change.is_a?(NomenclatureChange::NewName) }
  before_validation :populate_taxon_concept_fields,
    :if => Proc.new { |c| (c.new_record? || c.taxon_concept_id_changed?) && c.taxon_concept }

  def accepted_taxon_ids
    parse_pg_array(read_attribute(:accepted_taxon_ids)||"").compact
  end

  def accepted_taxon_ids=(ary)
    write_attribute(:accepted_taxon_ids, "{#{ary && ary.join(',')}}")
  end

  def fetch_accepted_taxons_full_name
    if accepted_taxon_ids.present?
      ActiveRecord::Base.connection.execute(
        <<-SQL
     SELECT tc.full_name FROM taxon_concepts tc WHERE tc.id = ANY (ARRAY#{accepted_taxon_ids.map(&:to_i)})
        SQL
      ).map{ |row| row['full_name']}.to_s
    end
  end

  def populate_taxon_concept_fields
    self.parent_id = taxon_concept.parent_id_changed? ? taxon_concept.parent_id_was : taxon_concept.parent_id
    self.rank_id = taxon_concept.rank_id_changed? ? taxon_concept.rank_id_was : taxon_concept.rank_id
    self.scientific_name = taxon_concept.full_name_changed? ? taxon_concept.full_name_was : taxon_concept.full_name
    self.author_year = taxon_concept.author_year_changed? ? taxon_concept.author_year_was : taxon_concept.author_year
    self.name_status = taxon_concept.name_status_changed? ? taxon_concept.name_status_was : taxon_concept.name_status
  end

  def new_full_name
    return nil if new_scientific_name.blank?
    rank = new_rank
    parent = new_parent || nomenclature_change.new_output_parent
    if parent && [Rank::SPECIES, Rank::SUBSPECIES].include?(rank.name)
      parent.full_name + ' ' + new_scientific_name
    elsif parent && rank.name == Rank::VARIETY
      parent.full_name + ' var. ' + new_scientific_name
    else
      new_scientific_name
    end
  end

  def display_full_name; new_full_name || taxon_concept.try(:full_name); end

  def display_rank_name
    try(:new_rank).try(:name) || taxon_concept.try(:rank).try(:name)
  end

  # Returns true when the new taxon has a different name from old one
  def will_create_taxon?
    taxon_concept.nil? ||
      new_scientific_name.present? &&
      taxon_concept.full_name != display_full_name
  end

  def will_create_taxon_from_another_taxon?
    !taxon_concept.nil? && will_create_taxon?
  end

  # Returns true when the new taxon has the same name as old one
  def will_update_taxon?
    !will_create_taxon? &&
      (!new_rank_id.blank? || !new_parent_id.blank? || !new_name_status.blank? || !new_author_year.blank?)
  end

  def tmp_taxon_concept
    taxon_concept_attrs = {
      :parent_id => new_parent_id || parent_id,
      :rank_id => new_rank_id || rank_id,
      :author_year => (new_author_year.present? ? new_author_year : author_year),
      :name_status => (new_name_status.present? ? new_name_status : name_status)
    }
    if will_create_taxon?
      taxonomy = (taxonomy_id.present? ? Taxonomy.find(taxonomy_id) :
        Taxonomy.find_by_name(Taxonomy::CITES_EU)
      )
      TaxonConcept.new(
        taxon_concept_attrs.merge({
          :taxonomy_id => taxonomy.id,
          :full_name => display_full_name,
        })
      ).tap do |tc|
        add_taxon_synonym(tc, accepted_taxon_ids)
        add_taxon_hybrid(tc, hybrid_parent_id)
        add_taxon_hybrid(tc, other_hybrid_parent_id)
      end
    elsif will_update_taxon?
      taxon_concept.assign_attributes(taxon_concept_attrs)
      taxon_concept
    else
      nil
    end
  end

  def add_taxon_synonym(tc, accepted_taxon_ids)
    accepted_taxon_ids.each do |accepted_taxon_id|
      tc.inverse_taxon_relationships.build(
        :taxon_concept_id => accepted_taxon_id,
        :taxon_relationship_type_id => TaxonRelationshipType.
        find_by_name(TaxonRelationshipType::HAS_SYNONYM).id
      )
    end
  end

  def add_taxon_hybrid(tc, other_taxon_id)
    tc.inverse_taxon_relationships.build(
      :taxon_concept_id => other_taxon_id,
      :taxon_relationship_type_id => TaxonRelationshipType.
      find_by_name(TaxonRelationshipType::HAS_HYBRID).id
    ) if other_taxon_id
  end

  def validate_tmp_taxon_concept
    @tmp_taxon_concept = tmp_taxon_concept
    return true if @tmp_taxon_concept.valid?
    @tmp_taxon_concept.errors.each do |attribute, message|
      if [:parent_id, :rank_id, :name_status, :author_year, :full_name].
        include?(attribute)
        errors.add(:"new_#{attribute}", message)
      else
        errors.add(:new_taxon_concept, message)
      end
    end
  end

  def needs_public_note?
    if nomenclature_change.is_a?(NomenclatureChange::StatusToSynonym) ||
      nomenclature_change.is_a?(NomenclatureChange::StatusSwap) &&
      new_name_status != 'A'
      false
    else
      true
    end
  end

  def taxon_name_already_existing?
    return !TaxonConcept.where("lower(full_name) = ?", display_full_name.downcase).empty?
  end

  def default_parent
    if name_status == 'T' &&
      Rank.in_range(Rank::VARIETY, Rank::SPECIES).include?(rank.name)
      TaxonConcept.where(
        taxonomy_id: Taxonomy.find_by_name(Taxonomy::CITES_EU).try(:id),
        rank_id: Rank.find_by_name(rank.parent_rank_name).try(:id),
        name_status: 'A'
      ).where(
        'UPPER(SQUISH_NULL(full_name)) = UPPER(?)',
        display_full_name.split.first
      ).first
    else
      new_parent
    end
  end

  def reassignables_by_class(reassignable_type)
    reassignable_type.constantize.where(
      :taxon_concept_id => taxon_concept.id
    )
  end

  def listing_changes_reassignments
    legislation_reassignments.where(
      reassignable_type: 'ListingChange'
    )
  end

  def cites_suspensions_reassignments
    legislation_reassignments.where(
      reassignable_type: 'CitesSuspension'
    )
  end

  def quotas_reassignments
    legislation_reassignments.where(
      reassignable_type: 'Quota'
    )
  end

  def eu_suspensions_reassignments
    legislation_reassignments.where(
      reassignable_type: 'EuSuspension'
    )
  end

  def eu_opinions_reassignments
    legislation_reassignments.where(
      reassignable_type: 'EuOpinion'
    )
  end

  def taxon_commons_reassignments
    reassignments.where(
      reassignable_type: 'TaxonCommon'
    )
  end

  def taxon_concept_references_reassignments
    reassignments.where(
      reassignable_type: 'TaxonConceptReference'
    )
  end

  def reassignment_class
    NomenclatureChange::OutputReassignment
  end

  def parent_reassignment_class
    NomenclatureChange::OutputParentReassignment
  end

  def name_reassignment_class
    NomenclatureChange::OutputNameReassignment
  end

  def distribution_reassignment_class
    NomenclatureChange::OutputDistributionReassignment
  end

  def legislation_reassignment_class
    NomenclatureChange::OutputLegislationReassignment
  end
end
