# == Schema Information
#
# Table name: nomenclature_change_output_reassignments
#
#  id                            :integer          not null, primary key
#  internal_note                 :text
#  note_en                       :text
#  note_es                       :text
#  note_fr                       :text
#  reassignable_type             :string(255)
#  type                          :string(255)      not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  created_by_id                 :integer          not null
#  nomenclature_change_output_id :integer          not null
#  reassignable_id               :integer
#  updated_by_id                 :integer          not null
#
# Foreign Keys
#
#  nomenclature_change_output_reassignments_created_by_id_fk  (created_by_id => users.id)
#  nomenclature_change_output_reassignments_output_id_fk      (nomenclature_change_output_id => nomenclature_change_outputs.id)
#  nomenclature_change_output_reassignments_updated_by_id_fk  (updated_by_id => users.id)
#

# Reassignable is a taxon concept that is reassigned to a new parent
class NomenclatureChange::OutputParentReassignment < NomenclatureChange::OutputReassignment
end
