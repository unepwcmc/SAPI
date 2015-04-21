# == Schema Information
#
# Table name: nomenclature_change_output_reassignments
#
#  id                            :integer          not null, primary key
#  nomenclature_change_output_id :integer          not null
#  type                          :string(255)      not null
#  reassignable_type             :string(255)
#  reassignable_id               :integer
#  note_en                       :text
#  created_by_id                 :integer          not null
#  updated_by_id                 :integer          not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  note_es                       :text
#  note_fr                       :text
#  internal_note                 :text
#

# Reassignable is a taxon relationship that is assigned to a new taxon concept
class NomenclatureChange::OutputNameReassignment < NomenclatureChange::OutputReassignment
end
