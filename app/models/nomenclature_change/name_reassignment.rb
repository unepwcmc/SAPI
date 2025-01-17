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
# Indexes
#
#  idx_on_nomenclature_change_input_id_837992fd1b            (nomenclature_change_input_id)
#  index_nomenclature_change_reassignments_on_created_by_id  (created_by_id)
#  index_nomenclature_change_reassignments_on_updated_by_id  (updated_by_id)
#
# Foreign Keys
#
#  nomenclature_change_reassignments_created_by_id_fk  (created_by_id => users.id)
#  nomenclature_change_reassignments_input_id_fk       (nomenclature_change_input_id => nomenclature_change_inputs.id)
#  nomenclature_change_reassignments_updated_by_id_fk  (updated_by_id => users.id)
#

# Reassignable is a taxon relationship that is assigned to a new taxon concept
class NomenclatureChange::NameReassignment < NomenclatureChange::Reassignment
  belongs_to :input, class_name: 'NomenclatureChange::Input',
    inverse_of: :name_reassignments,
    foreign_key: :nomenclature_change_input_id
end
