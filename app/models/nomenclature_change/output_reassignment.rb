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
# Indexes
#
#  idx_on_created_by_id_ac1c5548de                  (created_by_id)
#  idx_on_nomenclature_change_output_id_90bc77e905  (nomenclature_change_output_id)
#  idx_on_updated_by_id_b274995041                  (updated_by_id)
#
# Foreign Keys
#
#  nomenclature_change_output_reassignments_created_by_id_fk  (created_by_id => users.id)
#  nomenclature_change_output_reassignments_output_id_fk      (nomenclature_change_output_id => nomenclature_change_outputs.id)
#  nomenclature_change_output_reassignments_updated_by_id_fk  (updated_by_id => users.id)
#

# Represents a reassignment of taxon concept associations, which may be
# a side effect of a nomenclature change.
# For example, if the change involves swapping an accepted name and a synonym,
# the former accepted name's synonyms, distribution, legislation etc. will be
# assigned to the former synonym.
# The table uses an STI mechanism to differentiate between different types of
# associations.
# A polymorphic association is in place that links this object to the entitity
# that gets reassigned.
# For example the reassignable_type might be 'ListingChange'
class NomenclatureChange::OutputReassignment < ApplicationRecord
  include NomenclatureChange::ReassignmentHelpers

  belongs_to :output, class_name: 'NomenclatureChange::Output',
    foreign_key: :nomenclature_change_output_id
end
