class NomenclatureChange::ReassignmentTarget < ActiveRecord::Base
  attr_accessible :created_by_id, :nomenclature_change_output_id,
    :nomenclature_change_reassignment_id, :note, :updated_by_id
  belongs_to :output, :conditions => 'NOT is_input',
    :class_name => NomenclatureChange::Component,
    :foreign_key => :nomenclature_change_output_id
end
