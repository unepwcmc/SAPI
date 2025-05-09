# == Schema Information
#
# Table name: nomenclature_change_outputs
#
#  id                     :integer          not null, primary key
#  author_year            :string(255)
#  internal_note          :text             default("")
#  is_primary_output      :boolean          default(TRUE)
#  name_status            :string(255)
#  new_author_year        :string(255)
#  new_name_status        :string(255)
#  new_scientific_name    :string(255)
#  note_en                :text             default("")
#  note_es                :text             default("")
#  note_fr                :text             default("")
#  scientific_name        :string(255)
#  tag_list               :text             default("--- []\n")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  created_by_id          :integer          not null
#  new_parent_id          :integer
#  new_rank_id            :integer
#  new_taxon_concept_id   :integer
#  nomenclature_change_id :integer          not null
#  parent_id              :integer
#  rank_id                :integer
#  taxon_concept_id       :integer
#  taxonomy_id            :integer
#  updated_by_id          :integer          not null
#
# Indexes
#
#  index_nomenclature_change_outputs_on_created_by_id           (created_by_id)
#  index_nomenclature_change_outputs_on_new_parent_id           (new_parent_id)
#  index_nomenclature_change_outputs_on_new_rank_id             (new_rank_id)
#  index_nomenclature_change_outputs_on_new_taxon_concept_id    (new_taxon_concept_id)
#  index_nomenclature_change_outputs_on_nomenclature_change_id  (nomenclature_change_id)
#  index_nomenclature_change_outputs_on_taxon_concept_id        (taxon_concept_id)
#  index_nomenclature_change_outputs_on_updated_by_id           (updated_by_id)
#
# Foreign Keys
#
#  nomenclature_change_outputs_created_by_id_fk           (created_by_id => users.id)
#  nomenclature_change_outputs_new_parent_id_fk           (new_parent_id => taxon_concepts.id)
#  nomenclature_change_outputs_new_rank_id_fk             (new_rank_id => ranks.id)
#  nomenclature_change_outputs_new_taxon_concept_id_fk    (new_taxon_concept_id => taxon_concepts.id)
#  nomenclature_change_outputs_nomenclature_change_id_fk  (nomenclature_change_id => nomenclature_changes.id)
#  nomenclature_change_outputs_taxon_concept_id_fk        (taxon_concept_id => taxon_concepts.id)
#  nomenclature_change_outputs_updated_by_id_fk           (updated_by_id => users.id)
#

# Represents an output of a nomenclature change.
# Outputs may be new taxon concepts, created as a result of the nomenclature
# change.
class NomenclatureChange::Output < ApplicationRecord
  include TrackWhoDoesIt
  attr_accessor :output_type # New taxon, Existing subspecies, Existing taxon
  # Migrated to controller (Strong Parameters)
  # attr_accessible :nomenclature_change_id, :taxon_concept_id,
  #   :new_taxon_concept_id, :rank_id, :new_scientific_name, :new_author_year,
  #   :new_name_status, :new_parent_id, :new_rank_id, :taxonomy_id,
  #   :note_en, :note_es, :note_fr, :internal_note, :is_primary_output,
  #   :parent_reassignments_attributes, :name_reassignments_attributes,
  #   :distribution_reassignments_attributes, :legislation_reassignments_attributes,
  #   :output_type, :tag_list, :created_by_id, :updated_by_id

  belongs_to :nomenclature_change
  belongs_to :taxon_concept, optional: true
  belongs_to :parent, class_name: 'TaxonConcept', optional: true
  belongs_to :rank, optional: true
  belongs_to :new_taxon_concept, class_name: 'TaxonConcept', optional: true
  has_many :reassignments, inverse_of: :output,
    class_name: 'NomenclatureChange::OutputReassignment',
    foreign_key: :nomenclature_change_output_id, dependent: :destroy,
    autosave: true
  has_many :parent_reassignments, inverse_of: :output,
    class_name: 'NomenclatureChange::OutputParentReassignment',
    foreign_key: :nomenclature_change_output_id, dependent: :destroy,
    autosave: true
  has_many :name_reassignments, inverse_of: :output,
    class_name: 'NomenclatureChange::OutputNameReassignment',
    foreign_key: :nomenclature_change_output_id, dependent: :destroy,
    autosave: true
  has_many :distribution_reassignments, inverse_of: :output,
    class_name: 'NomenclatureChange::OutputDistributionReassignment',
    foreign_key: :nomenclature_change_output_id, dependent: :destroy,
    autosave: true
  has_many :legislation_reassignments, inverse_of: :output,
    class_name: 'NomenclatureChange::OutputLegislationReassignment',
    foreign_key: :nomenclature_change_output_id, dependent: :destroy,
    autosave: true
  has_many :reassignment_targets, inverse_of: :output,
    class_name: 'NomenclatureChange::ReassignmentTarget',
    foreign_key: :nomenclature_change_output_id, dependent: :destroy
  belongs_to :new_parent, class_name: 'TaxonConcept', optional: true
  belongs_to :new_rank, class_name: 'Rank', optional: true

  validates :new_scientific_name, presence: true,
    if: Proc.new { |c| c.taxon_concept_id.blank? }
  validates :new_parent_id, presence: true,
    if: Proc.new { |c| c.taxon_concept_id.blank? }
  validate :validate_tmp_taxon_concept,
    if: Proc.new { |c| (c.will_create_taxon? || c.will_update_taxon?) }
  before_validation :populate_taxon_concept_fields,
    if: Proc.new { |c| (c.new_record? || c.taxon_concept_id_changed?) && c.taxon_concept }

  def tag_list
    attr = read_attribute(:tag_list)
    return [] if attr.is_a?(String) && attr.match(/--- \[\]\n/).present?

    (attr || []).compact
  end

  def tag_list=(ary)
    write_attribute(:tag_list, "{#{ary && ary.join(',')}}")
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
    if parent && [ Rank::SPECIES, Rank::SUBSPECIES ].include?(rank.name)
      parent.full_name + ' ' + new_scientific_name
    elsif parent && rank.name == Rank::VARIETY
      parent.full_name + ' var. ' + new_scientific_name
    else
      new_scientific_name
    end
  end

  def display_full_name
    new_full_name || taxon_concept.try(:full_name)
  end

  def display_rank_name
    try(:new_rank).try(:name) || taxon_concept.try(:rank).try(:name)
  end

  # Returns true when the new taxon has a different name from old one
  def will_create_taxon?
    taxon_concept.nil? ||
      (new_scientific_name.present? &&
      taxon_concept.full_name != display_full_name)
  end

  def will_create_taxon_from_another_taxon?
    !taxon_concept.nil? && will_create_taxon?
  end

  # Returns true when the new taxon has the same name as old one
  def will_update_taxon?
    !will_create_taxon? &&
      (new_rank_id.present? || new_parent_id.present? || new_name_status.present? || new_author_year.present?)
  end

  def tmp_taxon_concept
    name_status_to_save = (new_name_status.presence || name_status)

    scientific_name =
      if [ 'A', 'N' ].include?(name_status_to_save) && display_full_name
        display_full_name.split.last
      else
        display_full_name
      end
    taxon_concept_attrs = {
      parent_id: new_parent_id || parent_id,
      rank_id: new_rank_id || rank_id,
      author_year: (new_author_year.presence || author_year),
      name_status: name_status_to_save,
      scientific_name: scientific_name
    }

    if will_create_taxon?
      taxonomy =
        if taxonomy_id.present?
          Taxonomy.find(taxonomy_id)
        else
          Taxonomy.find_by(name: Taxonomy::CITES_EU)
        end
      TaxonConcept.new(
        taxon_concept_attrs.merge(
          {
            taxonomy_id: taxonomy.id,
            tag_list: tag_list
          }
        )
      )
    elsif will_update_taxon?
      taxon_concept.assign_attributes(taxon_concept_attrs)
      taxon_concept
    else
      nil
    end
  end

  def validate_tmp_taxon_concept
    @tmp_taxon_concept = tmp_taxon_concept
    unless @tmp_taxon_concept
      errors.add(:new_taxon_concept, "can't be blank")
    end
    return true if @tmp_taxon_concept.valid?

    @tmp_taxon_concept.errors.each do |error|
      attribute = error.attribute
      message = error.message
      if [ :parent_id, :rank, :name_status, :author_year, :full_name ].
          include?(attribute)
        errors.add(:"new_#{attribute}", message)
      else
        errors.add(:new_taxon_concept, message)
      end
    end
  end

  def expected_parent_name
    if rank.name == Rank::SPECIES
      display_full_name.split[0]
    elsif [ Rank::SUBSPECIES, Rank::VARIETY ].include?(rank.name)
      display_full_name.split[0..1].join ' '
    else
      nil
    end
  end

  def default_parent
    if [ 'S', 'T' ].include?(name_status) &&
      parent_full_name = expected_parent_name
      TaxonConcept.where(
        taxonomy_id: Taxonomy.find_by(name: Taxonomy::CITES_EU).try(:id),
        rank_id: Rank.find_by(name: rank.parent_rank_name).try(:id),
        name_status: 'A'
      ).where(
        'UPPER(SQUISH_NULL(full_name)) = UPPER(?)',
        parent_full_name
      ).first
    else
      new_parent
    end
  end

  def reassignables_by_class(reassignable_type)
    reassignable_type.constantize.where(
      taxon_concept_id: taxon_concept.id
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
