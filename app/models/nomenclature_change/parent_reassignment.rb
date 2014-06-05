class NomenclatureChange::ParentReassignment < NomenclatureChange::Reassignment
  attr_accessible :reassignment_target_attributes
  has_one :reassignment_target, :class_name => NomenclatureChange::ReassignmentTarget,
    :foreign_key => :nomenclature_change_reassignment_id
  accepts_nested_attributes_for :reassignment_target, :allow_destroy => true
end
