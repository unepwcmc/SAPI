# == Schema Information
#
# Table name: nomenclature_change_reassignment_targets
#
#  id                                  :integer          not null, primary key
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  created_by_id                       :integer          not null
#  nomenclature_change_output_id       :integer          not null
#  nomenclature_change_reassignment_id :integer          not null
#  updated_by_id                       :integer          not null
#
# Indexes
#
#  idx_on_created_by_id_9d0424fa57                        (created_by_id)
#  idx_on_nomenclature_change_output_id_8c146310b0        (nomenclature_change_output_id)
#  idx_on_nomenclature_change_reassignment_id_f4d2638734  (nomenclature_change_reassignment_id)
#  idx_on_updated_by_id_50171fe98f                        (updated_by_id)
#
# Foreign Keys
#
#  nomenclature_change_reassignment_targets_created_by_id_fk    (created_by_id => users.id)
#  nomenclature_change_reassignment_targets_output_id_fk        (nomenclature_change_output_id => nomenclature_change_outputs.id)
#  nomenclature_change_reassignment_targets_reassignment_id_fk  (nomenclature_change_reassignment_id => nomenclature_change_reassignments.id)
#  nomenclature_change_reassignment_targets_updated_by_id_fk    (updated_by_id => users.id)
#

class NomenclatureChange::ReassignmentTarget < ApplicationRecord
  include TrackWhoDoesIt
  # Relationship table
  # attr_accessible :nomenclature_change_output_id,
  #   :nomenclature_change_reassignment_id, :note
  belongs_to :output, class_name: 'NomenclatureChange::Output',
    foreign_key: :nomenclature_change_output_id
  belongs_to :reassignment,
    class_name: 'NomenclatureChange::Reassignment',
    foreign_key: :nomenclature_change_reassignment_id
end
