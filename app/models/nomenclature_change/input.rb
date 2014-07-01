# Represents an input of a nomenclature change.
# Inputs are required to be existing taxon concepts.
class NomenclatureChange::Input < ActiveRecord::Base
  track_who_does_it
  attr_accessible :nomenclature_change_id, :taxon_concept_id,
    :note, :internal_note, :created_by_id, :updated_by_id,
    :parent_reassignments_attributes,
    :name_reassignments_attributes,
    :distribution_reassignments_attributes,
    :legislation_reassignments_attributes
  belongs_to :nomenclature_change
  belongs_to :taxon_concept
  has_many :reassignments, :inverse_of => :input,
    :class_name => NomenclatureChange::Reassignment,
    :foreign_key => :nomenclature_change_input_id, :dependent => :destroy,
    :autosave => true
  has_many :parent_reassignments, :inverse_of => :input,
    :class_name => NomenclatureChange::ParentReassignment,
    :foreign_key => :nomenclature_change_input_id, :dependent => :destroy,
    :autosave => true
  has_many :name_reassignments, :inverse_of => :input,
    :class_name => NomenclatureChange::NameReassignment,
    :foreign_key => :nomenclature_change_input_id, :dependent => :destroy,
    :autosave => true
  has_many :distribution_reassignments, :inverse_of => :input,
    :class_name => NomenclatureChange::DistributionReassignment,
    :foreign_key => :nomenclature_change_input_id, :dependent => :destroy,
    :autosave => true
  has_many :legislation_reassignments, :inverse_of => :input,
    :class_name => NomenclatureChange::LegislationReassignment,
    :foreign_key => :nomenclature_change_input_id, :dependent => :destroy,
    :autosave => true
  validates :nomenclature_change, :presence => true
  validates :taxon_concept, :presence => true
  accepts_nested_attributes_for :parent_reassignments, :allow_destroy => true
  accepts_nested_attributes_for :name_reassignments, :allow_destroy => true
  accepts_nested_attributes_for :distribution_reassignments, :allow_destroy => true
  accepts_nested_attributes_for :legislation_reassignments, :allow_destroy => true
end
