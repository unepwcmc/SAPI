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

  def process
    reassignment_targets.select do|target|
      target.output != input
    end.each do |target|
      if reassignable_id.blank?
        reassignables_by_class.each do |reassignable|
          process_target(target, reassignable)
        end
      else
        process_target(target, reassignable)
      end
    end
    unless outputs.include?(input)
      # input is not part of the split
      # delete original association
      if reassignable_id.blank?
        reassignables_by_class.each do |reassignable|
          reassignable.destroy
        end
      else
        reassignable.destroy
      end
    end
  end

  # all objects of reassignable_type that are linked to input taxon
  def reassignables_by_class
    Object::const_get(reassignable_type).where(
      :taxon_concept_id => input.taxon_concept.id
    )
  end

  private
  def process_target(target, reassignable)
    new_object = reassignable.clone
    # TODO for listing changes this needs to copy: annotations, listing distributions and exceptions
    # TODO for distributions this needs to copy distribution references
    # TODO for trade restrictions this needs to copy purpose / source / term links
    new_object.taxon_concept_id = target.output.taxon_concept_id #TODO synonym/subspecies
    # TODO in case synonyms / subspecies were selected as outputs
    # this needs to consider the new_taxon_concept_id
    # so any taxon creations need to be resolved earlier
    new_object.save
  end

end
