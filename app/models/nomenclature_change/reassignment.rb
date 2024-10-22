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
class NomenclatureChange::Reassignment < ApplicationRecord
  include NomenclatureChange::ReassignmentHelpers

  belongs_to :input, class_name: 'NomenclatureChange::Input',
    foreign_key: :nomenclature_change_input_id
end
