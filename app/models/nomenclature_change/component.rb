# Represents a component of a nomenclature change, i.e. an input or an output.
# Inputs are required to be existing taxon concepts.
# Outputs may be new taxon concepts, crated as a result of the nomenclature
# change.
class NomenclatureChange::Component < ActiveRecord::Base
  track_who_does_it
  attr_accessible :created_by_id, :is_input, :is_output,
    :nomenclature_change_id, :taxon_concept_id, :updated_by_id,
    :input_parent_reassignments_attributes,
    :input_name_reassignments_attributes
  belongs_to :taxon_concept
  has_many :input_parent_reassignments, :class_name => NomenclatureChange::ParentReassignment,
    :foreign_key => :nomenclature_change_input_id, :dependent => :destroy
  has_many :input_name_reassignments, :class_name => NomenclatureChange::NameReassignment,
    :foreign_key => :nomenclature_change_input_id, :dependent => :destroy
  validates_presence_of :taxon_concept_id, :if => Proc.new { |c| c.is_input }
  accepts_nested_attributes_for :input_parent_reassignments, :allow_destroy => true
  accepts_nested_attributes_for :input_name_reassignments, :allow_destroy => true
end
