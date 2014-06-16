# Represents an output of a nomenclature change.
# Outputs may be new taxon concepts, created as a result of the nomenclature
# change.
class NomenclatureChange::Output < ActiveRecord::Base
  track_who_does_it
  attr_accessible :created_by_id, :new_author_year, :new_scientific_name, :new_name_status, :new_parent_id, :new_rank_id, :new_taxon_concept_id, :nomenclature_change_id, :note, :taxon_concept_id, :updated_by_id
  belongs_to :nomenclature_change
  belongs_to :taxon_concept
  has_many :reassignment_targets, :class_name => NomenclatureChange::ReassignmentTarget,
    :foreign_key => :nomenclature_change_output_id, :dependent => :destroy
  belongs_to :new_parent, :class_name => TaxonConcept, :foreign_key => :new_parent_id
  belongs_to :new_rank, :class_name => Rank, :foreign_key => :new_rank_id
  validates :nomenclature_change_id, :presence => true
  validates :new_scientific_name, :presence => true,
    :if => Proc.new { |c| c.taxon_concept_id.blank? }
  validates :new_parent_id, :presence => true,
    :if => Proc.new { |c| c.taxon_concept_id.blank? }
  validate :validate_new_taxon_concept,
    :if => Proc.new { |c| c.will_create_taxon? || c.will_update_taxon? }

  def new_full_name
    return nil if new_scientific_name.blank?
    rank = new_rank || nomenclature_change.input.taxon_concept.rank
    parent = new_parent || nomenclature_change.input.taxon_concept.parent
    if [Rank::SPECIES, Rank::SUBSPECIES].include?(rank.name)
      parent && (parent.full_name + ' ') + new_scientific_name
    elsif rank.name == Rank::VARIETY
      parent && (parent.full_name + ' var. ') + new_scientific_name
    else
      name
    end
  end

  def display_full_name; new_full_name || taxon_concept.try(:full_name); end

  def process

  end

  # Returns true when the new taxon has a different name from old one
  def will_create_taxon?
    taxon_concept.nil? ||
      !new_scientific_name.blank? &&
      taxon_concept.full_name != display_full_name
  end

  # Returns true when the new taxon has the same name as old one
  def will_update_taxon?
    !will_create_taxon? &&
      (new_rank_id || new_parent_id || !new_name_status.blank? || !new_author_year.blank?)
  end

  def new_taxon_concept
    return @new_taxon_concept if @new_taxon_concept
    return nil unless will_create_taxon? || will_update_taxon?
    taxonomy = Taxonomy.find_by_name(Taxonomy::CITES_EU)
    @new_taxon_concept = taxon_concept || TaxonConcept.new(
      :taxonomy_id => taxonomy.id
    )
    @new_taxon_concept.parent_id = new_parent_id || taxon_concept.try(:parent_id)
    @new_taxon_concept.rank_id = new_rank_id || taxon_concept.try(:rank_id)
    @new_taxon_concept.full_name = display_full_name
    @new_taxon_concept.author_year = new_author_year || taxon_concept.try(:author_year)
    @new_taxon_concept.name_status = new_name_status || taxon_concept.try(:name_status)
    @new_taxon_concept
  end

  def validate_new_taxon_concept
    return true if new_taxon_concept.valid?
    new_taxon_concept.errors.each do |attribute, message|
      if [:parent_id, :rank_id, :name_status, :author_year, :full_name].
        include?(attribute)
        errors.add(:"new_#{attribute}", message)
      else
        errors.add(:new_taxon_concept, message)
      end
    end
  end

end
