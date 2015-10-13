# == Schema Information
#
# Table name: nomenclature_change_reassignments
#
#  id                           :integer          not null, primary key
#  nomenclature_change_input_id :integer          not null
#  type                         :string(255)      not null
#  reassignable_type            :string(255)
#  reassignable_id              :integer
#  note_en                      :text
#  note_es                      :text
#  note_fr                      :text
#  internal_note                :text
#  created_by_id                :integer          not null
#  updated_by_id                :integer          not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#

# Reassignable is a taxon concept that is reassigned to a new parent
class NomenclatureChange::ParentReassignment < NomenclatureChange::Reassignment
  attr_accessible :reassignment_target_attributes
  has_one :reassignment_target, :inverse_of => :reassignment,
    :class_name => NomenclatureChange::ReassignmentTarget,
    :foreign_key => :nomenclature_change_reassignment_id
  belongs_to :input, class_name: NomenclatureChange::Input,
    inverse_of: :parent_reassignments,
    foreign_key: :nomenclature_change_input_id
  accepts_nested_attributes_for :reassignment_target, :allow_destroy => true
end
