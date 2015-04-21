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
class NomenclatureChange::OutputReassignment < ActiveRecord::Base
  include NomenclatureChange::ReassignmentHelpers

  belongs_to :output, :class_name => NomenclatureChange::Output,
    :foreign_key => :nomenclature_change_output_id

  validates :output, :presence => true

end
