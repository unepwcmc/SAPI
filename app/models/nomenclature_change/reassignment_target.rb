class NomenclatureChange::ReassignmentTarget < ActiveRecord::Base
  track_who_does_it
  attr_accessible :created_by_id, :nomenclature_change_output_id,
    :nomenclature_change_reassignment_id, :note, :updated_by_id
  belongs_to :output, :class_name => NomenclatureChange::Output,
    :foreign_key => :nomenclature_change_output_id
  belongs_to :reassignment, :class_name => NomenclatureChange::Reassignment,
    :foreign_key => :nomenclature_change_reassignment_id

  validates :nomenclature_change_reassignment_id, :presence => true
  validates :nomenclature_change_output_id, :presence => true
end
