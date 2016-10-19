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

class NomenclatureChange::DocumentCitationReassignment < NomenclatureChange::Reassignment
  belongs_to :input, class_name: NomenclatureChange::Input,
    inverse_of: :document_citation_reassignments,
    foreign_key: :nomenclature_change_input_id
end
