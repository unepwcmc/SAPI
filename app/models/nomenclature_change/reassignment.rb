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
class NomenclatureChange::Reassignment < ActiveRecord::Base
  track_who_does_it
  attr_accessible :type, :reassignable_id, :reassignable_type,
    :nomenclature_change_input_id, :nomenclature_change_output_id,
    :note_en, :note_es, :note_fr, :internal_note, :output_ids
  belongs_to :reassignable, :polymorphic => true
  belongs_to :input, :class_name => NomenclatureChange::Input,
    :foreign_key => :nomenclature_change_input_id
  has_many :reassignment_targets, :inverse_of => :reassignment,
    :class_name => NomenclatureChange::ReassignmentTarget,
    :foreign_key => :nomenclature_change_reassignment_id,
    :dependent => :destroy, :autosave => true
  has_many :outputs, :through => :reassignment_targets

  validates :input, :presence => true
  validates :reassignable_type, :presence => true

  def note_with_resolved_placeholders_en(input, output)
    note_with_resolved_placeholders(note_en, input, output)
  end

  def note_with_resolved_placeholders_es(input, output)
    note_with_resolved_placeholders(note_es, input, output)
  end

  def note_with_resolved_placeholders_fr(input, output)
    note_with_resolved_placeholders(note_fr, input, output)
  end

  def internal_note_with_resolved_placeholders(input, output)
    note_with_resolved_placeholders(internal_note, input, output)
  end

  private

  def note_with_resolved_placeholders(note, input, output)
    note && note.
      sub(/\[\[input\]\]/, input.taxon_concept.full_name).
      sub(/\[\[output\]\]/, output.display_full_name) || ''
  end
end
