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
    :note, :output_ids
  belongs_to :reassignable, :polymorphic => true
  belongs_to :input, :class_name => NomenclatureChange::Input,
    :foreign_key => :nomenclature_change_input_id
  has_many :reassignment_targets, :class_name => NomenclatureChange::ReassignmentTarget,
    :foreign_key => :nomenclature_change_reassignment_id, :dependent => :destroy
  has_many :outputs, :through => :reassignment_targets
end
