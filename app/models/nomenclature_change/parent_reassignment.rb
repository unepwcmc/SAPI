# == Schema Information
#
# Table name: nomenclature_change_reassignments
#
#  id                           :integer          not null, primary key
#  internal_note                :text
#  note_en                      :text
#  note_es                      :text
#  note_fr                      :text
#  reassignable_type            :string(255)
#  type                         :string(255)      not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  created_by_id                :integer          not null
#  nomenclature_change_input_id :integer          not null
#  reassignable_id              :integer
#  updated_by_id                :integer          not null
#
# Foreign Keys
#
#  nomenclature_change_reassignments_created_by_id_fk  (created_by_id => users.id)
#  nomenclature_change_reassignments_input_id_fk       (nomenclature_change_input_id => nomenclature_change_inputs.id)
#  nomenclature_change_reassignments_updated_by_id_fk  (updated_by_id => users.id)
#

# Reassignable is a taxon concept that is reassigned to a new parent
class NomenclatureChange::ParentReassignment < NomenclatureChange::Reassignment
  # Migrated to controller (Strong Parameters)
  # attr_accessible :reassignment_target_attributes
  has_one :reassignment_target, :inverse_of => :reassignment,
    :class_name => 'NomenclatureChange::ReassignmentTarget',
    :foreign_key => :nomenclature_change_reassignment_id
  belongs_to :input, class_name: 'NomenclatureChange::Input',
    inverse_of: :parent_reassignments,
    foreign_key: :nomenclature_change_input_id
  accepts_nested_attributes_for :reassignment_target, :allow_destroy => true
end
